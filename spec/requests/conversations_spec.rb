require "rails_helper"

RSpec.describe "Conversations", type: :request do
  before { Flipper.enable(:ai_chatbot) }
  after  { Flipper.disable(:ai_chatbot) }

  describe "GET /conversations/new" do
    it "returns a successful response" do
      get new_conversation_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /conversations" do
    it "creates a conversation and redirects to it" do
      expect {
        post conversations_path
      }.to change(Conversation, :count).by(1)

      expect(response).to redirect_to(conversation_path(Conversation.last))
    end

    it "records the remote IP" do
      post conversations_path
      expect(Conversation.last.ip).to be_present
    end
  end

  describe "GET /conversations/:id" do
    let(:conversation) { create(:conversation) }

    it "returns a successful response" do
      get conversation_path(conversation)
      expect(response).to have_http_status(:ok)
    end
  end

  context "when :ai_chatbot flag is disabled" do
    before { Flipper.disable(:ai_chatbot) }

    it "returns 404 for new" do
      get new_conversation_path
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for create" do
      post conversations_path
      expect(response).to have_http_status(:not_found)
    end
  end
end
