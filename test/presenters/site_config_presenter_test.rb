require "test_helper"

class SiteConfigPresenterTest < ActiveSupport::TestCase
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

  test "hero_tagline returns value" do
    assert_equal "Hi, I'm Test.", build.hero_tagline
  end

  test "hero_tagline is html_safe" do
    assert build.hero_tagline.html_safe?
  end

  test "hero_description returns plain string" do
    assert_equal "A developer.", build.hero_description
  end

  test "about_text renders markdown to HTML" do
    result = build.about_text
    assert_includes result, "<strong>Bold text</strong>"
  end

  test "skills splits comma-separated string" do
    assert_equal ["Ruby", "Rails", "SQLite"], build.skills
  end

  test "skills strips whitespace" do
    presenter = build("skills" => " Ruby ,  Rails , SQLite ")
    assert_equal ["Ruby", "Rails", "SQLite"], presenter.skills
  end

  test "skills returns empty array when blank" do
    presenter = build("skills" => nil)
    assert_equal [], presenter.skills
  end

  test "contact returns value" do
    assert_equal "Get in touch.", build.contact
  end

  test "contact_email returns value" do
    assert_equal "test@example.com", build.contact_email
  end

  test "contact_github returns value" do
    assert_equal "https://github.com/test", build.contact_github
  end

  test "contact_linkedin returns value" do
    assert_equal "https://linkedin.com/in/test", build.contact_linkedin
  end

  test "profile_photo_path returns nil when config value is blank" do
    presenter = build("profile_photo_path" => "")
    assert_nil presenter.profile_photo_path
  end

  test "profile_photo_path returns nil when file does not exist" do
    presenter = build("profile_photo_path" => "nonexistent.png")
    assert_nil presenter.profile_photo_path
  end

  test "profile_photo_alt returns nil when photo path is blank" do
    presenter = build("profile_photo_path" => "")
    assert_nil presenter.profile_photo_alt
  end

  test "profile_photo_alt returns titleized filename without extension" do
    presenter = build("profile_photo_path" => "krzysztof-rygielski.png")
    presenter.define_singleton_method(:profile_photo_path) { "krzysztof-rygielski.png" }
    assert_equal "Krzysztof Rygielski", presenter.profile_photo_alt
  end
end
