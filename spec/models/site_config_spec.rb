require "rails_helper"

RSpec.describe SiteConfig, type: :model do
  before { SiteConfig.delete_all }

  it "get returns value for existing key" do
    create(:site_config_hero_tagline)
    expect(SiteConfig.get("hero_tagline")).to eq("Hi, I'm Krzysztof Rygielski.")
  end

  it "get returns nil for missing key" do
    expect(SiteConfig.get("nonexistent_key")).to be_nil
  end

  it "key must be unique" do
    create(:site_config_hero_tagline)
    duplicate = build(:site_config, key: "hero_tagline", value: "other")
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:key]).to include("has already been taken")
  end

  it "key must be present" do
    config = build(:site_config, key: "", value: "some value")
    expect(config).not_to be_valid
    expect(config.errors[:key]).to include("can't be blank")
  end
end
