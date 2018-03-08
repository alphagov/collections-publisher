require 'rails_helper'

RSpec.describe StepNavPublisher do
  let(:step_nav) { create(:step_by_step_page_with_steps) }

  before do
    stub_any_publishing_api_call
    allow(Services.publishing_api).to receive(:put_content)
  end

  context ".update" do
    it "sends the rendered step nav to the publishing api" do
      StepNavPublisher.update(step_nav)
      expect(Services.publishing_api).to have_received(:put_content)
    end
  end

end
