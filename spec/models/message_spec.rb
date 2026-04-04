require "rails_helper"

RSpec.describe Message, type: :model do
  let(:conversation) { create(:conversation) }

  subject(:message) { build(:message, conversation: conversation) }

  describe "validations" do
    it "is valid with role and content" do
      expect(message).to be_valid
    end

    it "is invalid without role" do
      message.role = nil
      expect(message).not_to be_valid
    end

    it "is invalid with unknown role" do
      message.role = "system"
      expect(message).not_to be_valid
    end

    it "is invalid without content" do
      message.content = nil
      expect(message).not_to be_valid
    end

    it "is invalid when content exceeds 2000 characters" do
      message.content = "a" * 2001
      expect(message).not_to be_valid
      expect(message.errors[:content]).to be_present
    end

    it "is valid at exactly 2000 characters" do
      message.content = "a" * 2000
      expect(message).to be_valid
    end
  end

  describe "ROLES" do
    it "includes user and assistant" do
      expect(Message::ROLES).to contain_exactly("user", "assistant")
    end
  end

  describe "associations" do
    it "belongs to conversation" do
      expect(Message.reflect_on_association(:conversation).macro).to eq(:belongs_to)
    end
  end
end
