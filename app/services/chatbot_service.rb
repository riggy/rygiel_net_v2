class ChatbotService < ApplicationService
  DEFAULT_MODEL = "claude-haiku-4-5-20251001"

  def initialize(system_prompt:, messages:)
    @system_prompt = system_prompt
    @messages      = messages
  end

  def call
    model = Rails.application.credentials.dig(:chatbot, :model_name).presence || DEFAULT_MODEL
    chat  = RubyLLM.chat(model:)
    chat.with_instructions(@system_prompt)
    @messages.each { |m| chat << { role: m[:role], content: m[:content] } }
    chat.complete.content
  end
end
