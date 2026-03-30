require "rails_helper"

RSpec.describe "Conversations::Messages", type: :request do
  let(:conversation) { Conversation.create!(ip: "127.0.0.1") }

  before { Flipper.enable(:ai_chatbot) }
  after  { Flipper.disable(:ai_chatbot) }

  describe "POST /conversations/:conversation_id/messages" do
    context "with valid content" do
      it "saves the user message" do
        expect {
          post conversation_messages_path(conversation),
               params:  { message: { content: "Hello there" } },
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.to change(Message, :count).by(1)

        expect(Message.last.role).to eq("user")
        expect(Message.last.content).to eq("Hello there")
      end

      it "enqueues GenerateChatResponseJob" do
        expect {
          post conversation_messages_path(conversation),
               params:  { message: { content: "Hello" } },
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.to have_enqueued_job(GenerateChatResponseJob)
      end

      it "returns a Turbo Stream response" do
        post conversation_messages_path(conversation),
             params:  { message: { content: "Hello" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end

      it "strips surrounding whitespace from content" do
        post conversation_messages_path(conversation),
             params:  { message: { content: "  spaces  " } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(Message.last.content).to eq("spaces")
      end

      it "redirects on HTML request" do
        post conversation_messages_path(conversation),
             params: { message: { content: "Hello" } }

        expect(response).to redirect_to(conversation_path(conversation))
      end
    end

    context "with blank content" do
      it "does not create a message" do
        expect {
          post conversation_messages_path(conversation),
               params:  { message: { content: "" } },
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.not_to change(Message, :count)
      end

      it "returns a Turbo Stream response with the form" do
        post conversation_messages_path(conversation),
             params:  { message: { content: "" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end
    end

    context "when :ai_chatbot flag is disabled" do
      before { Flipper.disable(:ai_chatbot) }

      it "returns 404" do
        post conversation_messages_path(conversation),
             params:  { message: { content: "Hello" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
