require 'rails_helper'

RSpec.describe StepByStepDraftUpdateWorker do
  before do
    allow(Services.publishing_api).to receive(:lookup_content_id)
    allow(StepLinksForRules).to receive(:update)
    allow(StepNavPublisher).to receive(:update)
    @current_user = create(:user, name: "New author")
  end

  context "step by step page exists" do
    let(:step_by_step_page) { create(:step_by_step_page_with_steps, assigned_to: "Original author") }

    it "updates the navigation rules, the publishing API, and the assignee" do
      described_class.new.perform(step_by_step_page.id, @current_user.name)

      expect(StepLinksForRules).to have_received(:update).with(step_by_step_page)
      expect(StepNavPublisher).to have_received(:update).with(step_by_step_page)
      expect(StepByStepPage.find(step_by_step_page.id).assigned_to).to eql "New author"
    end
  end

  describe '#update_assigned_to' do
    let(:step_by_step_page) { create(:step_by_step_page_with_steps, assigned_to: "Old author") }
    context 'when a guide is a new draft' do
      it 'should assign the draft to the current user' do
        described_class.new.perform(step_by_step_page.id, @current_user.name)
        expect(StepByStepPage.find(step_by_step_page.id).assigned_to).to eql "New author"
      end
    end
    context 'when a guide is a draft that has already been updated' do
      before do
        step_by_step_page.mark_draft_updated
      end
      it 'should remain assigned to the old author' do
        described_class.new.perform(step_by_step_page.id, @current_user.name)
        expect(StepByStepPage.find(step_by_step_page.id).assigned_to).to eql "Old author"
      end
    end
  end
end
