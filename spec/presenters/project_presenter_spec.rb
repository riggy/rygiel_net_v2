require "rails_helper"

RSpec.describe ProjectPresenter do
  let(:project) do
    Project.new(
      name: "My App",
      description: "A cool app",
      tech_tags: "Ruby, Rails"
    )
  end

  subject(:presenter) { described_class.new(project) }

  describe "#chatbot_context" do
    it "returns a formatted summary with name, description, and tags" do
      expect(presenter.chatbot_context).to eq("- **My App**: A cool app (Ruby, Rails)")
    end
  end
end
