require 'rails_helper'

RSpec.describe StepByStepScheduledPublishWorker do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
    allow(StepNavPublisher).to receive(:publish)
  end

  let(:step_by_step_page) { create(:step_by_step_page_with_steps) }

  it "publishes the step by step" do
    described_class.new.perform(step_by_step_page.id)

    expect(StepNavPublisher).to have_received(:publish).with(step_by_step_page)

    step_by_step_page.reload
    expect(step_by_step_page.has_been_published?).to be true
  end
end
