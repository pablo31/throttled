require "spec_helper"

describe Throttled do

  let(:limit_control){ Throttled.new }

  context 'Check token blocking for' do

    it "the 'limit reached' method" do
      token = generate_uniq_token

      now = Time.now
      is_blocked = limit_control.blocked? token
      expect(is_blocked).to eql false

      limit_control.limit_reached(token, 300, now)

      is_blocked = limit_control.blocked? token
      expect(is_blocked).to eql true

      is_blocked = limit_control.blocked_at?(token, now + 299)
      expect(is_blocked).to eql true

      is_blocked = limit_control.blocked_at?(token, now + 301)
      expect(is_blocked).to eql false
    end

  end

  context 'Check token rate limit for' do

    it '5 calls on 5 seconds' do
      token = generate_uniq_token

      limit_control.window_in_seconds = 1
      limit_control.rate_limit_in_window = 1
      limit_control.waiting_quota_in_seconds = 1

      time_1 = Time.now
      times = []
      5.times do |i|
        limit_control.limit_call token
        times << Time.now
      end
      last_time = nil
      times.each do |time|
        expect((time - last_time) >= 1).to eql true if last_time
        last_time = time
      end
    end

  end

end
