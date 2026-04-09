Rails.application.config.after_initialize do
  Trackguard::Visitor.has_one :whitelisted_ip
end
