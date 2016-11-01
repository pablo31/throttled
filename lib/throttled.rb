class Throttled

  def self.configure
    yield Configuration
  end

  RATE_KEY = 'throttled:rate:%{token}:%{window_code}'
  BLOCKED_KEY = 'throttled:blocked:%{token}'

  attr_accessor :redis, :window_in_seconds, :rate_limit_in_window, :waiting_quota_in_seconds

  def initialize(redis=nil, window_in_seconds=nil, rate_limit_in_window=nil, waiting_quota_in_seconds=nil)
    self.redis = redis || Configuration.redis_client
    self.window_in_seconds = window_in_seconds
    self.rate_limit_in_window = rate_limit_in_window
    self.waiting_quota_in_seconds = waiting_quota_in_seconds
  end

  def limit_call(token)
    if blocked?(token)
      raise TokenBlockedError.new(token)
    else
      check_rate(token)
      add_call_to_rate(token)
    end
  end

  def has_quota?(token)
    calls_count = calls_in_window(token, window_in_seconds)
    calls_count < rate_limit_in_window
  end

  def check_rate(token)
    waiting_time = 0
    loop do
      break if has_quota? token
      raise TokenTimeoutError.new(token) if waiting_time >= waiting_quota_in_seconds
      sleep(1)
      waiting_time += 1
    end
  end

  def add_call_to_rate(token)
    window_code = get_window_code(Time.now, @window_in_seconds)
    key = rate_key_for token, window_code
    @redis.multi do |multi|
      multi.incr(key)
      multi.expire(key, window_in_seconds)
    end
  end

  def limit_reached(token, expiration, now=nil)
    now ||= Time.now
    now_int = now.to_i
    key = blocked_key_for token
    @redis.set key, now_int + expiration, ex: expiration
  end

  def unblocking_time(token)
    key = blocked_key_for token
    value = @redis.get key
    Time.at(value.to_i) if value
  end

  def blocked?(token)
    !!blocked_at?(token, Time.now)
  end

  def blocked_at?(token, time)
    unlocking_time = unblocking_time(token)
    unlocking_time && (unlocking_time >= time)
  end

  protected

  def calls_in_window(token, window_in_seconds)
    window_code = get_window_code(Time.now, window_in_seconds)
    key = rate_key_for token, window_code
    calls_count = redis.get(key)
    calls_count ? calls_count.to_i : 0
  end

  def get_window_code(time, window_in_seconds)
    unix_time = time.to_i
    unix_time - unix_time.modulo(window_in_seconds)
  end

  def rate_key_for(token, window_code)
    RATE_KEY % { token: token, window_code: window_code }
  end

  def blocked_key_for(token)
    BLOCKED_KEY % { token: token }
  end

end

require 'redis'

require 'throttled/version'

require 'throttled/token_error'
require 'throttled/token_blocked_error'
require 'throttled/token_timeout_error'

require 'throttled/configuration'
