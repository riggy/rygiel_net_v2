require "rails_helper"

RSpec.describe "Admin::WhitelistedIps", type: :request do
  let(:token) { "test-analytics-token" }
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

  before do
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :analytics_token).and_return(token)
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :username).and_return("admin")
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :password).and_return("secret")
  end

  describe "POST /admin/whitelisted_ips" do
    it "creates a new whitelist entry with default 7-day expiry" do
      post "/admin/whitelisted_ips",
        params: { ip: "1.2.3.4" },
        headers: auth_headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data["status"]).to eq("ok")
      expect(data["ip"]).to eq("1.2.3.4")
      expect(data["expires_at"]).to be_present

      record = WhitelistedIp.find_by!(ip: "1.2.3.4")
      expect(record.expires_at).to be_within(5.seconds).of(7.days.from_now)
    end

    it "updates an existing entry (idempotent)" do
      WhitelistedIp.create!(ip: "1.2.3.4", expires_at: 1.day.from_now)

      post "/admin/whitelisted_ips",
        params: { ip: "1.2.3.4" },
        headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(WhitelistedIp.where(ip: "1.2.3.4").count).to eq(1)
      expect(WhitelistedIp.find_by!(ip: "1.2.3.4").expires_at).to be_within(5.seconds).of(7.days.from_now)
    end

    it "accepts a custom expires_at" do
      expires = 30.days.from_now.iso8601

      post "/admin/whitelisted_ips",
        params: { ip: "1.2.3.4", expires_at: expires },
        headers: auth_headers

      expect(response).to have_http_status(:ok)
      record = WhitelistedIp.find_by!(ip: "1.2.3.4")
      expect(record.expires_at).to be_within(5.seconds).of(30.days.from_now)
    end

    it "requires authentication" do
      post "/admin/whitelisted_ips", params: { ip: "1.2.3.4" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
