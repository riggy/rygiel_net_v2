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
      create(:site_config_about_text, value: "I'm a developer.")
      result = described_class.call
      expect(result).to include("About: I'm a developer.")
    end

    it "includes skills from SiteConfig" do
      create(:site_config_skills, value: "Ruby, Rails")
      result = described_class.call
      expect(result).to include("Skills: Ruby, Rails")
    end

    it "includes featured projects" do
      create(:project, :featured, name: "Cool App", description: "Does things", tech_tags: "Ruby")
      result = described_class.call
      expect(result).to include("**Cool App**")
      expect(result).to include("Does things")
    end

    it "excludes non-featured projects" do
      create(:project, name: "Hidden", description: "Secret", tech_tags: "Go")
      result = described_class.call
      expect(result).not_to include("Hidden")
    end

    it "includes published blog posts" do
      create(:post, :published, title: "My Post", body: "Some content here")
      result = described_class.call
      expect(result).to include("**My Post**")
    end

    it "excludes unpublished blog posts" do
      create(:post, title: "Draft", body: "Not ready")
      result = described_class.call
      expect(result).not_to include("Draft")
    end

    it "includes the latest now entry" do
      create(:now_entry, content: "Working on chatbot features")
      result = described_class.call
      expect(result).to include("Working on chatbot features")
    end

    it "returns empty string when no content exists" do
      result = described_class.call
      expect(result).to eq("")
    end

    it "limits blog posts to 5" do
      7.times { |i| create(:post, :published, title: "Post #{i}", published_at: i.days.ago) }
      result = described_class.call
      expect(result.scan(/\*\*Post \d\*\*/).size).to eq(5)
    end
  end
end
