class Throttled
  class Configuration

    class << self
      attr_accessor :redis_client
      attr_accessor :logger
    end

    # defaults
    self.redis_client = Redis.new
    self.logger = Loggers::SilentLogger.new

  end
end
