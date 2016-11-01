class Throttled
  class TokenBlockedError < TokenError

    def default_message
      "Token blocked: '#{token}'"
    end

  end
end
