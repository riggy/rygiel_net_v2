require "rails_helper"

RSpec.describe "CurriculumVitae", type: :request do
  describe "GET /cv" do
    context "when no CV exists" do
      it "returns ok with placeholder text" do
        get cv_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("CV coming soon")
      end
    end

    context "when a CV exists" do
      before { create(:curriculum_vitae) }

      it "returns ok and renders the content" do
        get cv_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Software developer")
      end

      it "includes a download link to the PDF" do
        get cv_path
        expect(response.body).to include(cv_path(format: :pdf))
      end
    end

    context "GET /cv.pdf" do
      before { create(:curriculum_vitae) }

      it "returns a PDF" do
        grover_double = instance_double(Grover, to_pdf: "%PDF-1.4 fake")
        allow(Grover).to receive(:new).and_return(grover_double)

        get cv_path(format: :pdf)

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/pdf")
      end
    end
  end

  describe "GET /cv/print" do
    context "when a CV exists" do
      before { create(:curriculum_vitae) }

      it "returns ok" do
        get cv_print_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when no CV exists" do
      it "returns ok" do
        get cv_print_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
