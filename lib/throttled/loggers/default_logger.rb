class Throttled
  module Loggers
    class DefaultLogger

      def trace(message)
        puts "TRACE #{message}"
      end

      def debug(message)
        puts "DEBUG #{message}"
      end

      def info(message)
        puts "INFO #{message}"
      end

      def warn(message)
        puts "WARN #{message}"
      end

      def error(message)
        puts "ERROR #{message}"
      end

    end
  end
end
