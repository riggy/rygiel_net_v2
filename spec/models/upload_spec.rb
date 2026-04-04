require "rails_helper"

RSpec.describe Upload, type: :model do
  describe "validations" do
    it "is valid with an attached image" do
      upload = Upload.new
      upload.file.attach(
        io: StringIO.new("fake image data"),
        filename: "photo.png",
        content_type: "image/png"
      )

      expect(upload).to be_valid
    end

    it "is invalid without an attached file" do
      upload = Upload.new

      expect(upload).not_to be_valid
      expect(upload.errors[:file]).to include("can't be blank")
    end

    it "is invalid with a non-image content type" do
      upload = Upload.new
      upload.file.attach(
        io: StringIO.new("not an image"),
        filename: "doc.pdf",
        content_type: "application/pdf"
      )

      expect(upload).not_to be_valid
      expect(upload.errors[:file]).to include("must be an image (PNG, JPEG, GIF, or WebP)")
    end

    it "accepts JPEG images" do
      upload = Upload.new
      upload.file.attach(
        io: StringIO.new("fake jpeg"),
        filename: "photo.jpg",
        content_type: "image/jpeg"
      )

      expect(upload).to be_valid
    end

    it "accepts WebP images" do
      upload = Upload.new
      upload.file.attach(
        io: StringIO.new("fake webp"),
        filename: "photo.webp",
        content_type: "image/webp"
      )

      expect(upload).to be_valid
    end
  end

end
