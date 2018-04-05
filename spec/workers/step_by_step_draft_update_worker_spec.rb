require 'rails_helper'

RSpec.describe StepByStepDraftUpdateWorker do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
    allow(StepLinksForRules).to receive(:update)
    allow(StepNavPublisher).to receive(:update)
  end

  context "step by step page exists" do
    let(:step_by_step_page) { create(:step_by_step_page_with_steps) }

    it "updates the navigation rules and updates the publishing API" do
      described_class.new.perform(step_by_step_page.id)

      expect(StepLinksForRules).to have_received(:update).with(step_by_step_page)
      expect(StepNavPublisher).to have_received(:update).with(step_by_step_page)
    end
  end
end
