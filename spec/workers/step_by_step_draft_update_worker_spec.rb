require "rails_helper"

RSpec.describe StepByStepDraftUpdateWorker do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
    allow(StepLinksForRules).to receive(:call)
    allow(StepNavPublisher).to receive(:update_draft)
    @current_user = create(:user, name: "New author")
  end

  context "step by step page exists" do
    let(:step_by_step_page) { create(:step_by_step_page_with_steps, assigned_to: "Original author") }

    it "updates the navigation rules, the publishing API, and the assignee" do
      described_class.new.perform(step_by_step_page.id, @current_user.name)

      expect(StepLinksForRules).to have_received(:call).with(step_by_step_page)
      expect(StepNavPublisher).to have_received(:update_draft).with(step_by_step_page)
      expect(StepByStepPage.find(step_by_step_page.id).assigned_to).to eql "New author"
    end
  end

  describe "#update_assigned_to" do
    let(:step_by_step_page) { create(:step_by_step_page_with_steps, assigned_to: "Old author") }
    context "when a guide is a new draft" do
      it "should assign the draft to the current user" do
        described_class.new.perform(step_by_step_page.id, @current_user.name)
        expect(StepByStepPage.find(step_by_step_page.id).assigned_to).to eql "New author"
      end
    end
    context "when a guide is a draft that has already been updated" do
      before do
        step_by_step_page.mark_draft_updated
      end
      it "should be assigned to the new author" do
        described_class.new.perform(step_by_step_page.id, @current_user.name)
        expect(StepByStepPage.find(step_by_step_page.id).assigned_to).to eql "New author"
      end
    end
    context "when a guide is a draft and its assignee is the current user" do
      let(:step_by_step_page) { create(:step_by_step_page_with_steps, assigned_to: "New author") }
      it "keeps the same assignee" do
        described_class.new.perform(step_by_step_page.id, @current_user.name)
        expect(step_by_step_page.assigned_to_changed?).to be false
      end
    end
  end

  describe "#generate_internal_change_note" do
    let(:step_by_step_page) { create(:step_by_step_page_with_steps) }
    context "when the guide is a new draft" do
      it 'generates a note that says "Draft saved"' do
        described_class.new.perform(step_by_step_page.id, @current_user.name)
        expect(step_by_step_page.internal_change_notes.first.headline).to eql "Draft saved"
      end
    end
    context "when the guide is a draft that has already been updated" do
      before do
        step_by_step_page.mark_draft_updated
      end
      it "should generate a change note" do
        described_class.new.perform(step_by_step_page.id, @current_user.name)
        expect(step_by_step_page.internal_change_notes.count).to eql 1
      end
    end
    context "when it is updated by the same user" do
      before do
        step_by_step_page.assigned_to = "New author"
        step_by_step_page.save!
      end
      it "should not generate a change note" do
        described_class.new.perform(step_by_step_page.id, @current_user.name)
        expect(step_by_step_page.internal_change_notes.count).to eql 0
      end
    end
  end
end
