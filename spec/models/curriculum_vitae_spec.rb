require "rails_helper"

RSpec.describe CurriculumVitae, type: :model do
  describe "validations" do
    it "is valid with content" do
      expect(build(:curriculum_vitae)).to be_valid
    end

    it "is invalid without content" do
      expect(build(:curriculum_vitae, content: nil)).not_to be_valid
    end
  end

  describe ".current" do
    context "when no record exists" do
      it "returns a new unpersisted instance" do
        cv = CurriculumVitae.current
        expect(cv).to be_a(CurriculumVitae)
        expect(cv).not_to be_persisted
      end
    end

    context "when a record exists" do
      it "returns the existing record" do
        existing = create(:curriculum_vitae)
        expect(CurriculumVitae.current).to eq(existing)
      end
    end
  end
end
