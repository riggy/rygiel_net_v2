require "rails_helper"

RSpec.describe GenerateChatResponseJob, type: :job do
  let(:conversation) { Conversation.create!(ip: "1.2.3.4") }

  before do
    conversation.messages.create!(role: "user", content: "Hello")
    allow(SiteConfig).to receive(:get).with("chatbot_system_prompt").and_return("You are helpful.")
  end

  describe "#perform" do
    context "when the API call succeeds" do
      before { allow(ChatbotService).to receive(:call).and_return("Hi there!") }

      it "creates an assistant message" do
        expect {
          described_class.perform_now(conversation.id)
        }.to change { conversation.messages.where(role: "assistant").count }.by(1)

        expect(conversation.messages.last.content).to eq("Hi there!")
      end

      it "broadcasts a message_created event over Action Cable" do
        expect {
          described_class.perform_now(conversation.id)
        }.to have_broadcasted_to(conversation.channel_name).with(
          hash_including(event: "message_created")
        )
      end

      it "updates last_activity_at on the conversation" do
        before = conversation.last_activity_at
        described_class.perform_now(conversation.id)
        expect(conversation.reload.last_activity_at).to be >= before
      end
    end

    context "when the API call raises an error" do
      before { allow(ChatbotService).to receive(:call).and_raise(StandardError, "API error") }

      it "saves the fallback message" do
        expect {
          described_class.perform_now(conversation.id)
        }.to change { conversation.messages.where(role: "assistant").count }.by(1)

        expect(conversation.messages.last.content).to eq(GenerateChatResponseJob::FALLBACK)
      end

      it "broadcasts the fallback over Action Cable" do
        expect {
          described_class.perform_now(conversation.id)
        }.to have_broadcasted_to(conversation.channel_name).with(
          hash_including(event: "message_created")
        )
      end
    end

    context "when the conversation does not exist" do
      it "returns without error" do
        expect { described_class.perform_now(999999) }.not_to raise_error
      end
    end
  end
end
