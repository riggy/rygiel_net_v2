Rails.application.config.after_initialize do
  Visitor.has_one :whitelisted_ip
end
