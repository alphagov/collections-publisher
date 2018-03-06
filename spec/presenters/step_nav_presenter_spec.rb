require 'rails_helper'

RSpec.describe StepNavPresenter do
  include GovukContentSchemaTestHelpers

  describe "#render_for_publishing_api" do
    let(:step_nav) { create(:step_by_step_page_with_steps) }
    subject { described_class.new(step_nav) }

    it "presents a step by step page in the correct format" do
      presented = subject.render_for_publishing_api
      expect(presented).to be_valid_against_schema('step_by_step_nav')
    end
  end
end
