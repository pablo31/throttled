$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "throttled"
require 'securerandom'

def generate_uniq_token
  SecureRandom.uuid.gsub("-", "").hex.to_s
end
