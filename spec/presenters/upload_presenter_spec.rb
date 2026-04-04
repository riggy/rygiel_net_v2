require "rails_helper"

RSpec.describe UploadPresenter do
  let(:upload) do
    u = Upload.new
    u.file.attach(
      io: StringIO.new("fake image data"),
      filename: "photo.png",
      content_type: "image/png"
    )
    u.save!
    u
  end

  subject(:presenter) { described_class.new(upload) }

  describe "#file_url" do
    it "returns a proxy path for the attached file" do
      expect(presenter.file_url).to include("/rails/active_storage/blobs/proxy/")
      expect(presenter.file_url).to include("photo.png")
    end
  end

  describe "#filename" do
    it "returns the filename as a string" do
      expect(presenter.filename).to eq("photo.png")
    end
  end
end