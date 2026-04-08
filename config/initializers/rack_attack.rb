Rack::Attack.blocklist("block known scanners") do |request|
  bad_agents = [
    # Generic scanners & vulnerability tools
    "masscan",
    "zgrab",
    "nmap",
    "nikto",
    "sqlmap",
    "nuclei",
    "gobuster",
    "dirbuster",
    "wfuzz",
    "ffuf",
    "burpsuite",
    "acunetix",
    "nessus",
    "openvas",
    "w3af",
    "skipfish",
    "arachni",
    # Search engine crawlers (block indexing bots)
    "googleother",
    "googlebot",
    "bingbot",
    # SEO & data harvesting bots
    "semrushbot",
    "ahrefsbot",
    "mj12bot",
    "dotbot",
    "blexbot",
    "petalbot",
    "bytespider",
    "claudebot",
    "gptbot",
    "ccbot",
    # Headless/automation browsers
    "headlesschrome",
    "phantomjs",
    # Generic scraper/crawler signals
    "scrapy",
    "python-requests",
    "go-http-client",
    "okhttp",
    "curl/",
    "wget/",
    # Old/legacy clients
    "konqueror/4",
    "jakarta",
    "java/",
    # Other
    "fasthttp",
    "palo alto",
    "cortex xpanse"
  ]

  user_agent = request.user_agent.to_s.downcase
  user_agent.empty? ||
    bad_agents.any? { |pattern| user_agent.include?(pattern) } ||
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
