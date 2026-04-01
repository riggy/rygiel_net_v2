require "rails_helper"

RSpec.describe ChatbotContext do
  before do
    SiteConfig.destroy_all
    Post.destroy_all
    Project.destroy_all
    NowEntry.destroy_all
  end

  describe ".call" do
    it "includes about text from SiteConfig" do
      SiteConfig.create!(key: "about_text", value: "I'm a developer.")
      result = described_class.call
      expect(result).to include("About: I'm a developer.")
    end

    it "includes skills from SiteConfig" do
      SiteConfig.create!(key: "skills", value: "Ruby, Rails")
      result = described_class.call
      expect(result).to include("Skills: Ruby, Rails")
    end

    it "includes featured projects" do
      Project.create!(name: "Cool App", description: "Does things", tech_tags: "Ruby", featured: true)
      result = described_class.call
      expect(result).to include("**Cool App**")
      expect(result).to include("Does things")
    end

    it "excludes non-featured projects" do
      Project.create!(name: "Hidden", description: "Secret", tech_tags: "Go", featured: false)
      result = described_class.call
      expect(result).not_to include("Hidden")
    end

    it "includes published blog posts" do
      Post.create!(title: "My Post", body: "Some content here", published: true, published_at: Time.current)
      result = described_class.call
      expect(result).to include("**My Post**")
    end

    it "excludes unpublished blog posts" do
      Post.create!(title: "Draft", body: "Not ready", published: false)
      result = described_class.call
      expect(result).not_to include("Draft")
    end

    it "includes the latest now entry" do
      NowEntry.create!(content: "Working on chatbot features")
      result = described_class.call
      expect(result).to include("Working on chatbot features")
    end

    it "returns empty string when no content exists" do
      result = described_class.call
      expect(result).to eq("")
    end

    it "limits blog posts to 5" do
      7.times { |i| Post.create!(title: "Post #{i}", body: "Body", published: true, published_at: i.days.ago) }
      result = described_class.call
      expect(result.scan(/\*\*Post \d\*\*/).size).to eq(5)
    end
  end
end
