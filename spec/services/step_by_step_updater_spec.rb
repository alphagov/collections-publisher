require "rails_helper"

RSpec.describe StepByStepUpdater do
  let(:current_user) { create(:user) }
  let(:review_requester) { create(:user) }
  let(:reviewer) { create(:user) }

  before do
    Sidekiq::Testing.fake!
    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api)
      .to receive(:lookup_content_ids)
      .and_return({})

    StepByStepUpdater.call(step_by_step, current_user)
  end

  after do
    expect(StepByStepDraftUpdateJob.jobs.size).to eq(1)
  end

  subject(:step_by_step_status) { step_by_step.status }

  context "does not revert to draft if a step by step in submitted_for_2i state is edited" do
    let(:step_by_step) { create(:step_by_step_page_submitted_for_2i, review_requester_id: review_requester.uid, reviewer_id: reviewer.uid) }
    it { is_expected.to eq "submitted_for_2i" }
  end

  context "does not revert to draft if a step by step in in_review state is edited" do
    let(:step_by_step) { create(:step_by_step_page_claimed_for_2i, review_requester_id: review_requester.uid, reviewer_id: reviewer.uid) }
    it { is_expected.to eq "in_review" }
  end

  context "does not revert to draft if a step by step in approved_2i state is edited" do
    let(:step_by_step) { create(:step_by_step_page_2i_approved, review_requester_id: review_requester.uid, reviewer_id: reviewer.uid) }
    it { is_expected.to eq "approved_2i" }
  end

  context "reverts to draft if a step by step in published state is edited" do
    let(:step_by_step) { create(:published_step_by_step_page) }
    it { is_expected.to eq "draft" }
  end

  context "reverts to draft if a step by step in scheduled state is edited" do
    let(:step_by_step) { create(:scheduled_step_by_step_page) }
    it { is_expected.to eq "draft" }
  end
end
