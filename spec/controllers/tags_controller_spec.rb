require 'rails_helper'

RSpec.describe TagsController do
  describe 'POST #publish_lists' do
    it "disallows normal users to publish lists for mainstream browse pages" do
      mainstream_browse_page = create(:mainstream_browse_page)

      post :publish_lists, params: { tag_id: mainstream_browse_page.content_id }

      expect(response.code).to eq('403')
    end

    it "allows only GDS Editors to publish lists for mainstream browse pages" do
      stub_user.permissions << "GDS Editor"
      mainstream_browse_page = create(:mainstream_browse_page)
      allow(PublishingAPINotifier).to receive(:notify)

      post :publish_lists, params: { tag_id: mainstream_browse_page.content_id }

      expect(response.code).to eq('302')
    end

    it "allows non-GDS Editors to publish lists for topic pages" do
      topic = create(:topic)
      allow(PublishingAPINotifier).to receive(:notify)

      post :publish_lists, params: { tag_id: topic.content_id }

      expect(response.code).to eq('302')
    end
  end
end
