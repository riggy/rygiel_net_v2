namespace :blocked_user_agents do
  desc "Seed initial blocked UA patterns into the database"
  task seed: :environment do
    patterns = [
      # Generic scanners & vulnerability tools
      "masscan", "zgrab", "nmap", "nikto", "sqlmap", "nuclei",
      "gobuster", "dirbuster", "wfuzz", "ffuf", "burpsuite",
      "acunetix", "nessus", "openvas", "w3af", "skipfish", "arachni",
      # Search engine crawlers
      "googleother", "googlebot", "bingbot",
      # SEO & data harvesting bots
      "semrushbot", "ahrefsbot", "mj12bot", "dotbot", "blexbot",
      "petalbot", "bytespider", "claudebot", "gptbot", "ccbot",
      # Headless/automation browsers
      "headlesschrome", "phantomjs",
      # Generic scraper/crawler signals
      "scrapy", "python-requests", "go-http-client", "okhttp",
      "curl/", "wget/",
      # Old/legacy clients
      "konqueror/4", "jakarta", "java/",
      # Other
      "fasthttp", "palo alto", "cortex xpanse"
    ]

    inserted = patterns.count { |p| BlockedUserAgent.find_or_create_by!(pattern: p).previously_new_record? }
    puts "Done: #{inserted} inserted, #{patterns.size - inserted} already existed (#{BlockedUserAgent.count} total)"
  end
end
