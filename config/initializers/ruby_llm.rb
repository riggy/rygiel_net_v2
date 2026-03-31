RubyLLM.configure do |config|
  config.anthropic_api_key = Rails.application.credentials.dig(:chatbot, :api_key)
end
