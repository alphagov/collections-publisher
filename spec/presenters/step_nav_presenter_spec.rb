require 'rails_helper'

RSpec.describe StepNavPresenter do
  include GovukContentSchemaTestHelpers

  describe "#render_for_publishing_api" do
    let(:step_nav) { create(:step_by_step_page_with_steps) }
    subject { described_class.new(step_nav) }

    it "presents a step by step page in the correct format" do
      presented = subject.render_for_publishing_api
      expect(presented).to be_valid_against_schema("step_by_step_nav")

      expect(presented[:base_path]).to eq("/how-to-be-the-amazing-1")
      expect(presented[:routes]).to eq([{ path: "/how-to-be-the-amazing-1", type: "exact" }])
    end

    it "copes with optional properties" do
      presented = subject.render_for_publishing_api
      steps = presented[:details][:step_by_step_nav][:steps]

      expect(steps[0][:optional]).to be false
      expect(steps[1][:optional]).to be true

      expect(steps[0][:logic]).to be nil
      expect(steps[1][:logic]).to eq "or"
    end

    it "presents edition links correctly" do
      presented = subject.render_for_publishing_api
      expect(presented[:links]).to eq({})
    end
  end
end
