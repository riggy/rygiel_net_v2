Rack::Attack.blocklist("block known scanners") do |request|
  patterns = Rails.cache.fetch("blocked_user_agent_patterns", expires_in: 10.minutes) do
    BlockedUserAgent.pluck(:pattern)
  end

  user_agent = request.user_agent.to_s.downcase
  user_agent.empty? ||
    patterns.any? { |p| user_agent.include?(p) } ||
    user_agent.strip == "mozilla/5.0"
end

Rack::Attack.safelist("allow local/dev") do |req|
  req.ip == "127.0.0.1"
end

Rack::Attack.safelist("allow whitelisted IPs") do |req|
  Rails.cache.fetch("whitelisted_ips", expires_in: 10.minutes) do
    WhitelistedIp.active.pluck(:ip)
  end.include?(req.ip)
end

Rack::Attack.throttle("requests by ip", limit: 100, period: 1.minute) do |request|
  request.ip
end

Rack::Attack.blocklist("flagged visitors") do |req|
  Rails.cache.fetch("flagged_ips", expires_in: 5.minutes) do
    Visitor.flagged.pluck(:ip)
  end.include?(req.ip)
end

# Chatbot rate limiting — max 10 messages per IP per minute
Rack::Attack.throttle("chat/ip", limit: 10, period: 1.minute) do |req|
  req.ip if req.path =~ /\A\/conversations\/\d+\/messages\z/ && req.post?
end
