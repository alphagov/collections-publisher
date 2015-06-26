require 'rails_helper'

RSpec.describe TopicsController do
  describe 'POST #publish' do
    it "disallows normal users to publish topics" do
      topic = create(:topic)

      post :publish, id: topic.content_id

      expect(response.code).to eq('403')
    end

    it "allows only GDS Editors to publish topics" do
      stub_user.permissions << "GDS Editor"
      topic = create(:topic)
      allow(PanopticonNotifier).to receive(:publish_tag)
      allow(PublishingAPINotifier).to receive(:send_to_publishing_api)
      allow_any_instance_of(RummagerNotifier).to receive(:notify)

      post :publish, id: topic.content_id

      expect(response.code).to eq('302')
    end
  end
end
