require "rails_helper"

RSpec.describe ChatbotService do
  let(:system_prompt) { "You are a helpful assistant." }
  let(:messages)      { [ { role: "user", content: "Hello" } ] }

  before do
    allow(Rails.application.credentials).to receive(:dig)
      .with(:chatbot, :model_name)
      .and_return("claude-haiku-4-5-20251001")
    allow(Rails.application.credentials).to receive(:dig)
      .with(:chatbot, :api_key)
      .and_return("test-key")
  end

  it "returns the assistant response content" do
    fake_response = double(content: "Hi there!")
    fake_chat     = double(with_instructions: nil, complete: fake_response)
    allow(fake_chat).to receive(:<<)
    allow(RubyLLM).to receive(:chat).and_return(fake_chat)

    result = described_class.call(system_prompt:, messages:)

    expect(result).to eq("Hi there!")
  end

  it "uses the model from credentials" do
    fake_response = double(content: "Hello!")
    fake_chat     = double(with_instructions: nil, complete: fake_response)
    allow(fake_chat).to receive(:<<)
    allow(RubyLLM).to receive(:chat).with(model: "claude-haiku-4-5-20251001").and_return(fake_chat)

    described_class.call(system_prompt:, messages:)

    expect(RubyLLM).to have_received(:chat).with(model: "claude-haiku-4-5-20251001")
  end

  it "falls back to DEFAULT_MODEL when credentials return nil" do
    allow(Rails.application.credentials).to receive(:dig)
      .with(:chatbot, :model_name)
      .and_return(nil)

    fake_response = double(content: "Hello!")
    fake_chat     = double(with_instructions: nil, complete: fake_response)
    allow(fake_chat).to receive(:<<)
    allow(RubyLLM).to receive(:chat).with(model: ChatbotService::DEFAULT_MODEL).and_return(fake_chat)

    described_class.call(system_prompt:, messages:)

    expect(RubyLLM).to have_received(:chat).with(model: ChatbotService::DEFAULT_MODEL)
  end
end
