require "rails_helper"

RSpec.describe "Admin::Emojis", type: :request do
  let(:credentials) { ActionController::HttpAuthentication::Basic.encode_credentials("admin", "secret") }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :username).and_return("admin")
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :password).and_return("secret")
  end

  it "returns JSON object mapping emoji names to unicode characters" do
    get "/admin/emojis.json", headers: { "Authorization" => credentials }

    expect(response).to have_http_status(:success)
    expect(response.content_type.split(";").first).to eq("application/json")

    data = JSON.parse(response.body)
    expect(data).to be_a(Hash)
    expect(data.key?("smile")).to be(true), "expected 'smile' emoji to be present"
    expect(data["smile"]).to match(/\p{Emoji}/)
  end

  it "returns multiple aliases for the same emoji" do
    get "/admin/emojis.json", headers: { "Authorization" => credentials }

    data = JSON.parse(response.body)
    expect(data.key?("+1")).to be(true), "expected '+1' alias to be present"
    expect(data.key?("thumbsup")).to be(true), "expected 'thumbsup' alias to be present"
    expect(data["+1"]).to eq(data["thumbsup"])
  end

  it "requires authentication" do
    get "/admin/emojis.json"

    expect(response).to have_http_status(:unauthorized)
  end
end
