require "rails_helper"

RSpec.describe ReferralLink, type: :model do
  describe "validations" do
    subject { build(:referral_link) }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "requires slug" do
      subject.slug = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:slug]).to be_present
    end

    it "requires slug to be unique" do
      create(:referral_link, slug: "linkedin")
      subject.slug = "linkedin"
      expect(subject).not_to be_valid
    end

    it "rejects slugs with uppercase letters" do
      subject.slug = "LinkedIn"
      expect(subject).not_to be_valid
    end

    it "rejects slugs with leading hyphens" do
      subject.slug = "-linkedin"
      expect(subject).not_to be_valid
    end

    it "rejects slugs with trailing hyphens" do
      subject.slug = "linkedin-"
      expect(subject).not_to be_valid
    end

    it "accepts slugs with internal hyphens" do
      subject.slug = "linkedin-cv"
      expect(subject).to be_valid
    end

    it "requires name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires target_path" do
      subject.target_path = nil
      expect(subject).not_to be_valid
    end

    it "rejects target_path not starting with /" do
      subject.target_path = "http://evil.com"
      expect(subject).not_to be_valid
      expect(subject.errors[:target_path]).to be_present
    end
  end

  describe "#destination_url" do
    it "appends ref=slug to a plain path" do
      link = build(:referral_link, slug: "linkedin-cv", target_path: "/cv")
      expect(link.destination_url).to eq("/cv?ref=linkedin-cv")
    end

    it "merges ref into existing query params" do
      link = build(:referral_link, slug: "gh", target_path: "/blog?tag=ruby")
      uri = URI.parse(link.destination_url)
      params = URI.decode_www_form(uri.query).to_h
      expect(params["ref"]).to eq("gh")
      expect(params["tag"]).to eq("ruby")
    end
  end

  describe "scopes" do
    it "active scope returns only active links" do
      active   = create(:referral_link)
      inactive = create(:referral_link, :inactive)
      expect(ReferralLink.active).to include(active)
      expect(ReferralLink.active).not_to include(inactive)
    end

    it "inactive scope returns only inactive links" do
      active   = create(:referral_link)
      inactive = create(:referral_link, :inactive)
      expect(ReferralLink.inactive).to include(inactive)
      expect(ReferralLink.inactive).not_to include(active)
    end
  end
end
