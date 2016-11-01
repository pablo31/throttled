class Throttled
  class Configuration

    class << self
      attr_accessor :redis_client
    end

    # defaults
    self.redis_client = Redis.new

  end
end
