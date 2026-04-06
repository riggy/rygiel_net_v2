require "rails_helper"

RSpec.describe "Admin::CurriculumVitae", type: :request do
  let(:headers) do
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "secret") }
  end

  before do
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :username).and_return("admin")
    allow(Rails.application.credentials).to receive(:dig).with(:admin, :password).and_return("secret")
  end

  describe "GET /admin/curriculum_vitae/edit" do
    it "requires authentication" do
      get edit_admin_curriculum_vitae_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns ok when authenticated" do
      get edit_admin_curriculum_vitae_path, headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /admin/curriculum_vitae" do
    it "creates the CV when none exists" do
      expect {
        patch admin_curriculum_vitae_path,
          params: { curriculum_vitae: { content: "# My CV" } },
          headers: headers
      }.to change(CurriculumVitae, :count).by(1)

      expect(response).to redirect_to(edit_admin_curriculum_vitae_path)
    end

    it "updates an existing CV" do
      create(:curriculum_vitae)
      patch admin_curriculum_vitae_path,
        params: { curriculum_vitae: { content: "# Updated CV" } },
        headers: headers

      expect(CurriculumVitae.current.content).to eq("# Updated CV")
      expect(response).to redirect_to(edit_admin_curriculum_vitae_path)
    end

    it "renders edit with unprocessable_entity on blank content" do
      patch admin_curriculum_vitae_path,
        params: { curriculum_vitae: { content: "" } },
        headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "requires authentication" do
      patch admin_curriculum_vitae_path,
        params: { curriculum_vitae: { content: "# My CV" } }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
