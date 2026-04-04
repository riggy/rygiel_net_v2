require "rails_helper"

RSpec.describe "Admin::Analytics", type: :request do
  let(:token) { "test-analytics-token" }
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

  before do
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :analytics_token).and_return(token)
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :username).and_return("admin")
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :password).and_return("secret")
  end

  describe "POST /admin/analytics/flag_visitor" do
    let!(:visitor) { Visitor.create!(ip: "1.2.3.4", first_seen_at: Time.current, last_seen_at: Time.current) }

    it "flags a visitor by IP" do
      Rails.cache.write("flagged_ips", [ "1.2.3.4" ])

      post "/admin/analytics/flag_visitor",
        params: { ip: "1.2.3.4", flag_reason: "spam", flagged_by: "admin" },
        headers: auth_headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data["status"]).to eq("ok")
      expect(data["ip"]).to eq("1.2.3.4")
      expect(data["flagged_at"]).to be_present
      expect(visitor.reload.flagged_at).to be_present
      expect(Rails.cache.read("flagged_ips")).to be_nil
    end

    it "returns 404 for unknown IP" do
      post "/admin/analytics/flag_visitor",
        params: { ip: "9.9.9.9", flag_reason: "spam", flagged_by: "admin" },
        headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      post "/admin/analytics/flag_visitor", params: { ip: "1.2.3.4" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /admin/analytics/unflag_visitor" do
    let!(:visitor) do
      Visitor.create!(
        ip: "1.2.3.4",
        first_seen_at: Time.current,
        last_seen_at: Time.current,
        flagged_at: Time.current,
        flag_reason: "spam",
        flagged_by: "admin"
      )
    end

    it "unflags a visitor by IP" do
      Rails.cache.write("flagged_ips", [ "1.2.3.4" ])

      delete "/admin/analytics/unflag_visitor",
        params: { ip: "1.2.3.4" },
        headers: auth_headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data["status"]).to eq("ok")
      expect(data["ip"]).to eq("1.2.3.4")

      visitor.reload
      expect(visitor.flagged_at).to be_nil
      expect(visitor.flag_reason).to be_nil
      expect(visitor.flagged_by).to be_nil
      expect(Rails.cache.read("flagged_ips")).to be_nil
    end

    it "returns 404 for unknown IP" do
      delete "/admin/analytics/unflag_visitor",
        params: { ip: "9.9.9.9" },
        headers: auth_headers

      expect(response).to have_http_status(:not_found)
    end

    it "requires authentication" do
      delete "/admin/analytics/unflag_visitor", params: { ip: "1.2.3.4" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
