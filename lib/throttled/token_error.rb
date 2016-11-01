class Throttled
  class TokenError < RuntimeError

    # abstract class
    # child must implement 'default_message()'

    attr_accessor :token

    def initialize(token)
      self.token = token
      super default_message
    end

  end
end
