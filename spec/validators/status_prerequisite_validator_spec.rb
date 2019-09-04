require 'rails_helper'

RSpec.describe StatusPrerequisiteValidator do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  context "#scheduled" do
    let(:step_by_step_page) { build(:step_by_step_page) }
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
end
