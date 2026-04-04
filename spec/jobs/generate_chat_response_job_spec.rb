require "rails_helper"

RSpec.describe GenerateChatResponseJob, type: :job do
  let(:conversation) { create(:conversation) }

  before do
    create(:message, :user, conversation: conversation, content: "Hello")
    allow(SiteConfig).to receive(:get).with("chatbot_system_prompt").and_return("You are helpful.")
    allow(ChatbotContext).to receive(:call).and_return("## Skills\nRuby, Rails")
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

      it "broadcasts a remove for the thinking indicator" do
        expect(Turbo::StreamsChannel).to receive(:broadcast_remove_to).with(
          conversation,
          target: ActionView::RecordIdentifier.dom_id(conversation, :thinking)
        )
        allow(Turbo::StreamsChannel).to receive(:broadcast_append_to)

        described_class.perform_now(conversation.id)
      end

      it "broadcasts an append for the assistant message" do
        allow(Turbo::StreamsChannel).to receive(:broadcast_remove_to)
        expect(Turbo::StreamsChannel).to receive(:broadcast_append_to).with(
          conversation,
          hash_including(
            target:  ActionView::RecordIdentifier.dom_id(conversation, :messages),
            partial: "conversations/message"
          )
        )

        described_class.perform_now(conversation.id)
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

      it "still broadcasts the fallback" do
        allow(Turbo::StreamsChannel).to receive(:broadcast_remove_to)
        expect(Turbo::StreamsChannel).to receive(:broadcast_append_to)

        described_class.perform_now(conversation.id)
      end
    end

    context "when the conversation does not exist" do
      it "returns without error" do
        expect { described_class.perform_now(999999) }.not_to raise_error
      end
    end
  end
end
