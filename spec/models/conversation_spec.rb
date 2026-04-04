require "rails_helper"

RSpec.describe Conversation, type: :model do
  subject(:conversation) { build(:conversation) }

  describe "validations" do
    it "is valid with ip and last_activity_at" do
      expect(conversation).to be_valid
    end

    it "is invalid without ip" do
      conversation.ip = nil
      expect(conversation).not_to be_valid
      expect(conversation.errors[:ip]).to be_present
    end
  end

  describe "associations" do
    it "belongs to visitor optionally" do
      expect(Conversation.reflect_on_association(:visitor).options[:optional]).to be(true)
    end

    it "has many messages" do
      expect(Conversation.reflect_on_association(:messages).macro).to eq(:has_many)
    end

    it "destroys messages when destroyed" do
      conversation.save!
      conversation.messages.create!(role: "user", content: "hello")
      expect { conversation.destroy }.to change(Message, :count).by(-1)
    end
  end

  describe "#channel_name" do
    it "returns conversation_<id>" do
      conversation.save!
      expect(conversation.channel_name).to eq("conversation_#{conversation.id}")
    end
  end

  describe "before_validation" do
    it "sets last_activity_at on create" do
      conversation.save!
      expect(conversation.last_activity_at).to be_present
    end
  end

  describe ".recent" do
    it "orders by last_activity_at descending" do
      old_conv = create(:conversation, last_activity_at: 2.hours.ago)
      new_conv = create(:conversation, last_activity_at: 1.hour.ago)
      expect(Conversation.recent.first).to eq(new_conv)
      expect(Conversation.recent.last).to eq(old_conv)
    end
  end
end
