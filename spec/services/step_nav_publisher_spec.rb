require 'rails_helper'

RSpec.describe StepNavPublisher do
  let(:step_nav) { create(:step_by_step_page_with_steps) }

  before do
    stub_any_publishing_api_call
    allow(Services.publishing_api).to receive(:put_content)
    allow(Services.publishing_api).to receive(:lookup_content_id)
  end

  context ".update" do
    it "sends the rendered step nav to the publishing api" do
      allow(StepNavPublisher).to receive(:lookup_content_ids).and_return('/foo' => 'a-content-id')
      StepNavPublisher.update(step_nav)
      expect(Services.publishing_api).to have_received(:put_content)
    end

    context "live step by step having a step edited" do
      let(:step_nav) { create(:published_step_by_step_page) }

      it "defines :access_limited in the publishing-api payload" do
        StepNavPublisher.update(step_nav)
        content_id = /[0-9a-f]{5,40}/ # changes on each test run, as does Array value below
        payload = hash_including(:access_limited => { :auth_bypass_ids => instance_of(Array) })
        expect(Services.publishing_api).to have_received(:put_content).with(content_id, payload)
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
end
