require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.describe StepNavPublisher do
  include GdsApi::TestHelpers::PublishingApi

  let(:step_nav) { create(:step_by_step_page_with_steps) }
  let(:review_requester_user) { create(:user) }
  let(:reviewer_user) { create(:user) }

  before do
    stub_any_publishing_api_call
    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  context ".update" do
    it "sends the rendered step nav to the publishing api" do
      allow(StepNavPublisher).to receive(:lookup_content_ids).and_return("/foo" => "a-content-id")
      StepNavPublisher.update(step_nav)
      expect(Services.publishing_api).to have_received(:put_content)
    end

    context "published step by step having a step edited" do
      let(:step_nav) { create(:published_step_by_step_page) }

      it "defines :access_limited in the publishing-api payload" do
        StepNavPublisher.update(step_nav)
        content_id = /[0-9a-f]{5,40}/ # changes on each test run, as does Array value below
        payload = hash_including(:access_limited => { :auth_bypass_ids => instance_of(Array) })
        expect(Services.publishing_api).to have_received(:put_content).with(content_id, payload)
      end
    end

    context "step by step being edited" do
      let(:step_nav) { create(:step_by_step_page_with_steps) }

      it "does not revert to draft if a step by step in submitted_for_2i state is edited" do
        step_nav.update_attributes(status: "submitted_for_2i", review_requester_id: review_requester_user.uid, reviewer_id: reviewer_user.uid)
        StepNavPublisher.update(step_nav)
        expect(step_nav.status).to eq "submitted_for_2i"
      end

      it "does not revert to draft if a step by step in in_review state is edited" do
        step_nav.update_attributes(status: "in_review", review_requester_id: review_requester_user.uid, reviewer_id: reviewer_user.uid)
        StepNavPublisher.update(step_nav)
        expect(step_nav.status).to eq "in_review"
      end

      it "does not revert to draft if a step by step in approved_2i state is edited" do
        step_nav.update_attributes(status: "approved_2i", review_requester_id: review_requester_user.uid, reviewer_id: reviewer_user.uid)
        StepNavPublisher.update(step_nav)
        expect(step_nav.status).to eq "approved_2i"
      end

      it "reverts to draft if a step by step in published state is edited" do
        step_nav.update_attributes(status: "published")
        StepNavPublisher.update(step_nav)
        expect(step_nav.status).to eq "draft"
      end

      it "reverts to draft if a step by step in scheduled state is edited" do
        step_nav.update_attributes(status: "scheduled")
        StepNavPublisher.update(step_nav)
        expect(step_nav.status).to eq "draft"
      end
    end
  end

  context ".lookup_content_ids" do
    it "calls the publishing_api end point" do
      allow(Services.publishing_api).to receive(:lookup_content_ids)
      StepNavPublisher.lookup_content_ids(["/foo", "/bar"])

      expect(Services.publishing_api).to have_received(:lookup_content_ids)
    end
  end

  context ".schedule_for_publishing" do
    let(:step_nav) { create(:draft_step_by_step_page, scheduled_at: Date.tomorrow) }

    before do
      presenter = StepNavPresenter.new(step_nav)
      @publishing_api_request = stub_publishing_api_put_intent(presenter.base_path, presenter.scheduling_payload)
    end

    it "adds a scheduled job to the queue" do
      Sidekiq::Testing.fake! do
        expect {
          StepNavPublisher.schedule_for_publishing(step_nav)
        }.to change(StepByStepScheduledPublishWorker.jobs, :size).by(1)
      end
    end

    it "tells publishing-api to expect a scheduled job" do
      StepNavPublisher.schedule_for_publishing(step_nav)
      expect(@publishing_api_request).to have_been_requested
    end
  end

  context ".cancel_scheduling" do
    let(:step_nav) { create(:draft_step_by_step_page, scheduled_at: Date.tomorrow) }

    before do
      base_path = StepNavPresenter.new(step_nav).base_path
      @publishing_api_request = stub_publishing_api_destroy_intent(base_path)
    end

    it "tells publishing-api a scheduled job has been cancelled" do
      StepNavPublisher.cancel_scheduling(step_nav)
      expect(@publishing_api_request).to have_been_requested
    end
  end
end
