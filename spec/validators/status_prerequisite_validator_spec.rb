require 'rails_helper'

RSpec.describe StatusPrerequisiteValidator do
  let(:step_by_step_page) { build(:step_by_step_page) }

  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  context "#in_review" do
    let(:error_message) { "in_review, requires a draft, a reviewer and for status to be submitted_for_2i" }

    it "does not allow status to be in_review if reviewer_id is missing" do
      step_by_step_page.reviewer_id = nil
      step_by_step_page.status = "in_review"

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors.messages[:status]).to eq([error_message])
    end

    it "does not allow status to be in_review if there is no draft" do
      allow(step_by_step_page).to receive(:has_draft?).and_return(false)
      step_by_step_page.reviewer_id = SecureRandom.uuid
      step_by_step_page.status = "in_review"

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors.messages[:status]).to eq([error_message])
    end

    it "does not allow status to be in_review if the current status is not submitted_for_2i" do
      allow(step_by_step_page).to receive(:has_draft?).and_return(true)
      step_by_step_page.reviewer_id = SecureRandom.uuid
      step_by_step_page.status = "in_review"

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors.messages[:status]).to eq([error_message])
    end
  end

  context "#2i_approved" do
    let(:error_message) { "2i_approved, requires a draft, a reviewer and for status to be in_review" }

    it "does not allow status to be 2i_approved if there is no draft" do
      allow(step_by_step_page).to receive(:has_draft?).and_return(false)
      step_by_step_page.status = "2i_approved"

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors.messages[:status]).to eq([error_message])
    end

    it "does not allow status to be 2i_approved if the current status is not in_review" do
      allow(step_by_step_page).to receive(:has_draft?).and_return(true)
      step_by_step_page.status = "2i_approved"

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors.messages[:status]).to eq([error_message])
    end

    it "allows status to be 2i_approved if the current status is in_review and there is a draft" do
      allow(step_by_step_page).to receive(:has_draft?).and_return(true)
      allow(step_by_step_page).to receive(:status_was). and_return("in_review")
      step_by_step_page.status = "2i_approved"

      expect(step_by_step_page).to be_valid
    end
  end

  context "#scheduled" do
    let(:error_message) { "scheduled, requires a draft and scheduled_at date to be present" }

    it "does not allow status to be scheduled if scheduled_at is missing" do
      step_by_step_page.scheduled_at = nil
      step_by_step_page.status = "scheduled"

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors.messages[:status]).to eq([error_message])
    end

    it "does not allow status to be scheduled if there is no draft" do
      allow(step_by_step_page).to receive(:has_draft?).and_return(false)
      step_by_step_page.scheduled_at = 1.hour.from_now
      step_by_step_page.status = "scheduled"

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors.messages[:status]).to eq([error_message])
    end
  end

  context "#submitted_for_2i" do
    let(:error_message) { "submitted_for_2i, requires a draft and review_requester_id to be present" }

    it "does not allow status to be submitted_for_2i if review_requester_id is missing" do
      step_by_step_page.status = "submitted_for_2i"

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors.messages[:status]).to eq([error_message])
    end

    it "does not allow status to be submitted_for_2i if there is no draft" do
      allow(step_by_step_page).to receive(:has_draft?).and_return(false)
      step_by_step_page.status = "submitted_for_2i"
      step_by_step_page.review_requester_id = SecureRandom.uuid

      expect(step_by_step_page).not_to be_valid
      expect(step_by_step_page.errors.messages[:status]).to eq([error_message])
    end
  end
end
