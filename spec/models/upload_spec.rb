require "rails_helper"

RSpec.describe Upload, type: :model do
  describe "validations" do
    it "is valid with an attached image" do
      expect(build(:upload)).to be_valid
    end

    it "is invalid without an attached file" do
      upload = Upload.new
      expect(upload).not_to be_valid
      expect(upload.errors[:file]).to include("can't be blank")
    end

    it "is invalid with a non-image content type" do
      upload = build(:upload, :non_image)
      expect(upload).not_to be_valid
      expect(upload.errors[:file]).to include("must be an image (PNG, JPEG, GIF, or WebP)")
    end

    it "accepts JPEG images" do
      expect(build(:upload, :jpeg)).to be_valid
    end

    it "accepts WebP images" do
      expect(build(:upload, :webp)).to be_valid
    end
  end
end
