require "rails_helper"

RSpec.describe SiteConfigPresenter do
  def build(overrides = {})
    defaults = {
      "hero_tagline"       => "Hi, I'm Test.",
      "hero_description"   => "A developer.",
      "about_text"         => "**Bold text** paragraph.",
      "skills"             => "Ruby, Rails, SQLite",
      "contact"            => "Get in touch.",
      "contact_email"      => "test@example.com",
      "contact_github"     => "https://github.com/test",
      "contact_linkedin"   => "https://linkedin.com/in/test",
      "profile_photo_path" => "photo.png"
    }
    SiteConfigPresenter.new(defaults.merge(overrides))
  end

  it "hero_tagline returns value" do
    expect(build.hero_tagline).to eq("Hi, I'm Test.")
  end

  it "hero_tagline is html_safe" do
    expect(build.hero_tagline).to be_html_safe
  end

  it "hero_description returns plain string" do
    expect(build.hero_description).to eq("A developer.")
  end

  it "about_text renders markdown to HTML" do
    expect(build.about_text).to include("<strong>Bold text</strong>")
  end

  it "skills splits comma-separated string" do
    expect(build.skills).to eq([ "Ruby", "Rails", "SQLite" ])
  end

  it "skills strips whitespace" do
    presenter = build("skills" => " Ruby ,  Rails , SQLite ")
    expect(presenter.skills).to eq([ "Ruby", "Rails", "SQLite" ])
  end

  it "skills returns empty array when blank" do
    presenter = build("skills" => nil)
    expect(presenter.skills).to eq([])
  end

  it "contact returns value" do
    expect(build.contact).to eq("Get in touch.")
  end

  it "contact_email returns value" do
    expect(build.contact_email).to eq("test@example.com")
  end

  it "contact_github returns value" do
    expect(build.contact_github).to eq("https://github.com/test")
  end

  it "contact_linkedin returns value" do
    expect(build.contact_linkedin).to eq("https://linkedin.com/in/test")
  end

  it "profile_photo_path returns nil when config value is blank" do
    presenter = build("profile_photo_path" => "")
    expect(presenter.profile_photo_path).to be_nil
  end

  it "profile_photo_path returns nil when file does not exist" do
    presenter = build("profile_photo_path" => "nonexistent.png")
    expect(presenter.profile_photo_path).to be_nil
  end

  it "profile_photo_alt returns nil when photo path is blank" do
    presenter = build("profile_photo_path" => "")
    expect(presenter.profile_photo_alt).to be_nil
  end

  it "profile_photo_alt returns titleized filename without extension" do
    presenter = build("profile_photo_path" => "krzysztof-rygielski.png")
    presenter.define_singleton_method(:profile_photo_path) { "krzysztof-rygielski.png" }
    expect(presenter.profile_photo_alt).to eq("Krzysztof Rygielski")
  end

  describe "#chatbot_context" do
    it "includes about text and skills" do
      result = build.chatbot_context
      expect(result).to include("About: **Bold text** paragraph.")
      expect(result).to include("Skills: Ruby, Rails, SQLite")
    end

    it "includes contact info" do
      result = build.chatbot_context
      expect(result).to include("Contact: test@example.com")
      expect(result).to include("GitHub: https://github.com/test")
      expect(result).to include("LinkedIn: https://linkedin.com/in/test")
    end

    it "omits blank fields" do
      result = build("about_text" => "", "skills" => nil).chatbot_context
      expect(result).not_to include("About:")
      expect(result).not_to include("Skills:")
    end
  end
end
