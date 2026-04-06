require "rails_helper"

RSpec.describe "Admin::ReferralLinks", type: :request do
  let(:auth_headers) do
    { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "secret") }
  end

  before do
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :username).and_return("admin")
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :password).and_return("secret")
  end

  describe "GET /admin/referral_links" do
    it "requires authentication" do
      get "/admin/referral_links"
      expect(response).to have_http_status(:unauthorized)
    end

    it "lists referral links" do
      create(:referral_link, name: "LinkedIn")
      get "/admin/referral_links", headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("LinkedIn")
    end
  end

  describe "GET /admin/referral_links/new" do
    it "renders the new form" do
      get "/admin/referral_links/new", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/referral_links" do
    let(:valid_params) do
      { referral_link: { slug: "linkedin-cv", name: "LinkedIn CV", target_path: "/cv", active: true } }
    end

    it "creates a referral link and redirects" do
      expect {
        post "/admin/referral_links", params: valid_params, headers: auth_headers
      }.to change(ReferralLink, :count).by(1)

      expect(response).to redirect_to(admin_referral_links_path)
    end

    it "does not allow setting clicks via mass assignment" do
      post "/admin/referral_links",
        params: { referral_link: valid_params[:referral_link].merge(clicks: 999) },
        headers: auth_headers
      expect(ReferralLink.last.clicks).to eq(0)
    end

    it "renders new with errors for invalid params" do
      post "/admin/referral_links",
        params: { referral_link: { slug: "", name: "", target_path: "" } },
        headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "rejects external target_path" do
      post "/admin/referral_links",
        params: { referral_link: { slug: "x", name: "X", target_path: "http://evil.com" } },
        headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /admin/referral_links/:id/edit" do
    let!(:link) { create(:referral_link) }

    it "renders the edit form" do
      get "/admin/referral_links/#{link.id}/edit", headers: auth_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/referral_links/:id" do
    let!(:link) { create(:referral_link, name: "Old Name") }

    it "updates the referral link" do
      patch "/admin/referral_links/#{link.id}",
        params: { referral_link: { name: "New Name" } },
        headers: auth_headers
      expect(link.reload.name).to eq("New Name")
      expect(response).to redirect_to(admin_referral_links_path)
    end

    it "can deactivate a link" do
      patch "/admin/referral_links/#{link.id}",
        params: { referral_link: { active: false } },
        headers: auth_headers
      expect(link.reload.active).to be false
    end
  end

  describe "DELETE /admin/referral_links/:id" do
    let!(:link) { create(:referral_link) }

    it "destroys the referral link" do
      expect {
        delete "/admin/referral_links/#{link.id}", headers: auth_headers
      }.to change(ReferralLink, :count).by(-1)
      expect(response).to redirect_to(admin_referral_links_path)
    end
  end
end
