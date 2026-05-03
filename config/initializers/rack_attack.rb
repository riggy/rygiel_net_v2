# Trackguard rules (scanner blocklist, IP whitelist, flagged visitors, local safelist, IP throttle)
# are registered automatically by the Trackguard engine.

# Chatbot rate limiting — max 10 messages per IP per minute
Rack::Attack.throttle("chat/ip", limit: 10, period: 1.minute) do |req|
  req.ip if req.path =~ /\A\/conversations\/\d+\/messages\z/ && req.post?
end
