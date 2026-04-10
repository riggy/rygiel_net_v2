Rails.application.config.to_prepare do
  Trackguard::Visitor.has_one :whitelisted_ip
end
