require "rails_helper"

RSpec.describe "Trackguard::Admin::BlockedUserAgents", type: :request do
  let(:token) { "test-analytics-token" }
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

  before do
    Trackguard::BlockedUserAgent.delete_all
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :analytics_token).and_return(token)
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :username).and_return("admin")
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :password).and_return("secret")
  end

  describe "GET /trackguard/admin/blocked_user_agents" do
    it "returns a JSON array of all patterns" do
      Trackguard::BlockedUserAgent.create!(pattern: "masscan")
      Trackguard::BlockedUserAgent.create!(pattern: "zgrab")

      get "/trackguard/admin/blocked_user_agents", headers: auth_headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data).to contain_exactly("masscan", "zgrab")
    end

    it "returns an empty array when no patterns exist" do
      get "/trackguard/admin/blocked_user_agents", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it "requires authentication" do
      get "/trackguard/admin/blocked_user_agents"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /trackguard/admin/blocked_user_agents" do
    it "creates a new blocked UA pattern" do
      Rails.cache.write(Trackguard::BlockedUserAgent::CACHE_KEY, [])

      post "/trackguard/admin/blocked_user_agents",
        params: { pattern: "evilbot/1.0" },
        headers: auth_headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data["status"]).to eq("ok")
      expect(data["pattern"]).to eq("evilbot/1.0")

      expect(Trackguard::BlockedUserAgent.find_by(pattern: "evilbot/1.0")).not_to be_nil
      expect(Rails.cache.read(Trackguard::BlockedUserAgent::CACHE_KEY)).to be_nil
    end

    it "is idempotent — does not create duplicates" do
      Trackguard::BlockedUserAgent.create!(pattern: "evilbot/1.0")

      post "/trackguard/admin/blocked_user_agents",
        params: { pattern: "evilbot/1.0" },
        headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(Trackguard::BlockedUserAgent.where(pattern: "evilbot/1.0").count).to eq(1)
    end

    it "returns 422 when pattern param is missing" do
      post "/trackguard/admin/blocked_user_agents",
        params: {},
        headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["status"]).to eq("error")
    end

    it "requires authentication" do
      post "/trackguard/admin/blocked_user_agents", params: { pattern: "evilbot/1.0" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
