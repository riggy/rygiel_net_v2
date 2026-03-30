require "rails_helper"

RSpec.describe ChatChannel, type: :channel do
  let(:conversation) { Conversation.create!(ip: "1.2.3.4") }

  it "subscribes and streams from the conversation channel" do
    subscribe(conversation_id: conversation.id)

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from(conversation.channel_name)
  end

  it "rejects subscription for a non-existent conversation" do
    subscribe(conversation_id: 999999)

    expect(subscription).to be_rejected
  end
end
