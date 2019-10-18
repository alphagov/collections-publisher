require "rails_helper"

RSpec.describe StepNavActionsHelper do
  include CommonFeatureSteps
  include LinkChecker

  let(:step_by_step_page) { create(:draft_step_by_step_page) }
  let(:user) { create(:user) }
  let(:reviewer_user) { create(:user, permissions: required_permissions_for_2i) }
  let(:second_reviewer_user) { create(:user, permissions: required_permissions_for_2i) }
  let(:non_2i_user) { create(:user, permissions: required_permissions_for_2i - ["2i reviewer"]) }

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

    it "returns false if the reviewer is not a 2i reviewer" do
      step_by_step_page.status = "submitted_for_2i"
      step_by_step_page.review_requester_id = user.uid
      expect(helper.can_review?(step_by_step_page, non_2i_user)).to be false
    end
  end

  describe "#can_submit_2i_review?" do
    it "returns false if the step by step is not in review" do
      step_by_step_page.status = "submitted_for_2i"
      step_by_step_page.review_requester_id = user.uid
      expect(helper.can_submit_2i_review?(step_by_step_page, user)).to be false
    end

    it "returns false if the current user is not the reviewer" do
      step_by_step_page.status = "in_review"
      step_by_step_page.review_requester_id = user.uid
      step_by_step_page.reviewer_id = reviewer_user.uid
      expect(helper.can_submit_2i_review?(step_by_step_page, second_reviewer_user)).to be false
    end

    it "returns true if the step by step is in review and the current user is the reviewer and they have permissions" do
      step_by_step_page.status = "in_review"
      step_by_step_page.review_requester_id = user.uid
      step_by_step_page.reviewer_id = reviewer_user.uid
      expect(helper.can_submit_2i_review?(step_by_step_page, reviewer_user)).to be true
    end
  end

  describe "#must_check_for_broken_links?" do
    it "returns false if there aren't any steps" do
      step_by_step_page = create(:step_by_step_page)

      expect(helper.must_check_for_broken_links?(step_by_step_page)).to be false
    end

    context "steps with links" do
      it "returns true if there are internal links and link checker hasn't been run" do
        step_by_step_page = create(:draft_step_by_step_page)

        expect(helper.must_check_for_broken_links?(step_by_step_page)).to be true
      end

      it "returns true if there are external links and link checker hasn't been run" do
        step_by_step_page = create(:step_by_step_page)
        create(:step, step_by_step_page: step_by_step_page, contents: "- [Good stuff](http://foo.co.uk/good/stuff)")

        expect(helper.must_check_for_broken_links?(step_by_step_page)).to be true
      end

      it "returns true if link checker hasn't been run since the last update" do
        step_by_step_page = create(:draft_step_by_step_page)
        stub_link_checker_report_success(step_by_step_page.steps.first)
        create(:link_report, step: step_by_step_page.steps.first, created_at: 1.day.ago)

        expect(helper.must_check_for_broken_links?(step_by_step_page)).to be true
      end

      it "returns false if link checker has been run and there are no broken links" do
        step_by_step_page = create(:draft_step_by_step_page)
        stub_link_checker_report_success(step_by_step_page.steps.first)

        expect(helper.must_check_for_broken_links?(step_by_step_page)).to be false
      end
    end
  end
end
