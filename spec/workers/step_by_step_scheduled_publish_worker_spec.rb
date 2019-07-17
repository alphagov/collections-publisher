require 'rails_helper'

RSpec.describe StepByStepScheduledPublishWorker do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
    allow(StepNavPublisher).to receive(:publish)
  end

  let(:step_by_step_page) { create(:draft_step_by_step_page, scheduled_at: Time.now) }


  it "publishes the step by step" do
    described_class.new.perform(step_by_step_page.id)

    expect(StepNavPublisher).to have_received(:publish).with(step_by_step_page)

    step_by_step_page.reload
    expect(step_by_step_page.has_been_published?).to be true
  end

  it "generates a change note" do
    described_class.new.perform(step_by_step_page.id)
    expect(step_by_step_page.internal_change_notes.first.description).to eq("Published on schedule")
  end

  it "doesn't publish the step by step if it isn't scheduled" do
    step_by_step_page = create(:draft_step_by_step_page)
    described_class.new.perform(step_by_step_page.id)

    expect(StepNavPublisher).to_not have_received(:publish)

    step_by_step_page.reload
    expect(step_by_step_page.has_been_published?).to be false
  end

  it "doesn't publish a step by step scheduled in the future" do
    step_by_step_page = create(:draft_step_by_step_page, scheduled_at: Time.now + 1.hour)
    described_class.new.perform(step_by_step_page.id)

    expect(StepNavPublisher).to_not have_received(:publish)

    step_by_step_page.reload
    expect(step_by_step_page.has_been_published?).to be false
  end
end
