require "test_helper"

class SiteConfigTest < ActiveSupport::TestCase
  test "get returns value for existing key" do
    assert_equal "Hi, I'm Krzysztof Rygielski.", SiteConfig.get("hero_tagline")
  end

  test "get returns nil for missing key" do
    assert_nil SiteConfig.get("nonexistent_key")
  end

  test "key must be unique" do
    duplicate = SiteConfig.new(key: "hero_tagline", value: "other")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:key], "has already been taken"
  end

  test "key must be present" do
    config = SiteConfig.new(key: "", value: "some value")
    assert_not config.valid?
    assert_includes config.errors[:key], "can't be blank"
  end
end
