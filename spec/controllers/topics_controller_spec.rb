require "rails_helper"

RSpec.describe TopicsController do
  describe "POST #publish" do
    it "disallows normal users to publish topics" do
      topic = create(:topic)

      post :publish, params: { id: topic.content_id }

      expect(response.code).to eq("403")
    end

    it "allows only GDS Editors to publish topics" do
      stub_user.permissions << "GDS Editor"
      stub_any_publishing_api_call

      topic = create(:topic)
      allow(PublishingAPINotifier).to receive(:notify)

      post :publish, params: { id: topic.content_id }

      expect(response.code).to eq("302")
    end
  end
end
