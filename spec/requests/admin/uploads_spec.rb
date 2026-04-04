require "rails_helper"

RSpec.describe "Admin::Uploads", type: :request do
  let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials("admin", "secret") }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :username).and_return("admin")
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :password).and_return("secret")
  end

  describe "POST /admin/uploads" do
    it "requires authentication" do
      post "/admin/uploads"

      expect(response).to have_http_status(:unauthorized)
    end

    it "uploads a valid image and returns JSON with url and filename" do
      file = Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/files/test_image.png"),
        "image/png"
      )

      post "/admin/uploads", params: { file: file }, headers: { "Authorization" => credentials }

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data["url"]).to be_present
      expect(data["url"]).to include("/rails/active_storage/blobs/proxy/")
      expect(data["filename"]).to eq("test_image.png")
    end

    it "rejects non-image files" do
      file = Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/files/test_document.txt"),
        "text/plain"
      )

      post "/admin/uploads", params: { file: file }, headers: { "Authorization" => credentials }

      expect(response).to have_http_status(:unprocessable_entity)
      data = JSON.parse(response.body)
      expect(data["error"]).to include("must be an image")
    end

    it "rejects requests without a file" do
      post "/admin/uploads", headers: { "Authorization" => credentials }

      expect(response).to have_http_status(:unprocessable_entity)
      data = JSON.parse(response.body)
      expect(data["error"]).to include("can't be blank")
    end
  end
end
