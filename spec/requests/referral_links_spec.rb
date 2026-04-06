require "rails_helper"

RSpec.describe "ReferralLinks", type: :request do
  describe "GET /go/:slug" do
    context "with an active link" do
      let!(:link) { create(:referral_link, slug: "linkedin-cv", target_path: "/cv", clicks: 0) }

      it "redirects to the destination with ref param" do
        get "/go/linkedin-cv"
        expect(response).to redirect_to("/cv?ref=linkedin-cv")
        expect(response).to have_http_status(:found)
      end

      it "increments the click counter" do
        expect {
          get "/go/linkedin-cv"
        }.to change { link.reload.clicks }.by(1)
      end

      it "does not increment clicks for bots" do
        expect {
          get "/go/linkedin-cv", headers: { "User-Agent" => "Googlebot/2.1" }
        }.not_to change { link.reload.clicks }
      end

      it "preserves existing query params in target_path" do
        link.update!(target_path: "/blog?tag=ruby")
        get "/go/linkedin-cv"
        expect(response.location).to include("tag=ruby")
        expect(response.location).to include("ref=linkedin-cv")
      end
    end

    context "with an inactive link" do
      let!(:link) { create(:referral_link, :inactive, slug: "old-link") }

      it "redirects to root with 301" do
        get "/go/old-link"
        expect(response).to have_http_status(:moved_permanently)
      end

      it "does not increment clicks" do
        expect {
          get "/go/old-link"
        }.not_to change { link.reload.clicks }
      end
    end

    context "with an unknown slug" do
      it "redirects to root with 301" do
        get "/go/nonexistent"
        expect(response).to have_http_status(:moved_permanently)
      end
    end
  end
end
