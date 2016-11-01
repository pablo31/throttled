class Throttled
  class TokenTimeoutError < TokenError

    def default_message
      "Timeout waiting for quota: '#{token}'"
    end

  end
end
