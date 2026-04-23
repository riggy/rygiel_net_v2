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

  describe "GET /admin/analytics" do
    it "requires authentication" do
      get "/admin/analytics", headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns totals, top_pages, top_referrers, top_sources and recent page views" do
      visitor = create(:visitor, ip: "1.2.3.4")
      create(:page_view, visitor: visitor, path: "/", referer: "https://google.com")

      get "/admin/analytics", headers: auth_headers.merge("Accept" => "application/json")

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data).to include("totals", "top_pages", "top_referrers", "top_sources", "recent")
      expect(data["totals"]).to include("today", "week", "month")
    end

    it "includes source in top_sources when page views have a source" do
      visitor = create(:visitor, ip: "1.2.3.4")
      create(:page_view, :with_source, visitor: visitor)

      get "/admin/analytics", headers: auth_headers.merge("Accept" => "application/json")

      data = JSON.parse(response.body)
      expect(data["top_sources"]).to include("linkedin" => 1)
    end

    it "includes flagging info in recent page views" do
      visitor = create(:visitor, :flagged, ip: "1.2.3.4")
      create(:page_view, visitor: visitor)

      get "/admin/analytics", headers: auth_headers.merge("Accept" => "application/json")

      pv = JSON.parse(response.body)["recent"].first
      expect(pv["ip"]).to eq("1.2.3.4")
      expect(pv["flagged_at"]).to be_present
      expect(pv["flagged_by"]).to be_present
      expect(pv["whitelisted"]).to be false
    end

    it "shows whitelisted true when visitor has an active whitelist entry" do
      visitor = create(:visitor, ip: "1.2.3.4")
      create(:whitelisted_ip, ip: visitor.ip, visitor: visitor)
      create(:page_view, visitor: visitor)

      get "/admin/analytics", headers: auth_headers.merge("Accept" => "application/json")

      pv = JSON.parse(response.body)["recent"].first
      expect(pv["whitelisted"]).to be true
    end

    it "shows whitelisted false when visitor whitelist entry is expired" do
      visitor = create(:visitor, ip: "1.2.3.4")
      create(:whitelisted_ip, :expired, ip: visitor.ip, visitor: visitor)
      create(:page_view, visitor: visitor)

      get "/admin/analytics", headers: auth_headers.merge("Accept" => "application/json")

      pv = JSON.parse(response.body)["recent"].first
      expect(pv["whitelisted"]).to be false
    end
  end
end
