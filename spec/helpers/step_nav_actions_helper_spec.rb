require "rails_helper"

RSpec.describe StepNavActionsHelper do
  let(:step_by_step_page) { create(:draft_step_by_step_page) }
  let(:user) { create(:user) }
  let(:reviewer_user) { create(:user) }
  let(:second_reviewer_user) { create(:user) }

  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  describe "#can_review?" do
    it "returns false if the step-by-step has not been submitted for 2i" do
      expect(helper.can_review?(step_by_step_page, user)).to be false
    end

    it "returns false if the user who requested a review trys to claim the review" do
      step_by_step_page.status = "submitted_for_2i"
      step_by_step_page.review_requester_id = user.uid
      expect(helper.can_review?(step_by_step_page, user)).to be false
    end

    it "returns true if another user tries to claim the review" do
      step_by_step_page.status = "submitted_for_2i"
      step_by_step_page.review_requester_id = user.uid
      expect(helper.can_review?(step_by_step_page, reviewer_user)).to be true
    end

    it "returns true if another reviewer tries to take over the review" do
      step_by_step_page.status = "in_review"
      step_by_step_page.review_requester_id = user.uid
      step_by_step_page.reviewer_id = reviewer_user.uid
      expect(helper.can_review?(step_by_step_page, second_reviewer_user)).to be true
    end

    it "returns false if the reviewer tries to claim review again" do
      step_by_step_page.status = "in_review"
      step_by_step_page.review_requester_id = user.uid
      step_by_step_page.reviewer_id = reviewer_user.uid
      expect(helper.can_review?(step_by_step_page, reviewer_user)).to be false
    end
  end
end
