require 'rails_helper'

RSpec.describe TagsController do
  describe 'POST #republish' do
    it "disallows normal users to republish mainstream browse pages" do
      mainstream_browse_page = create(:mainstream_browse_page)

      post :republish, tag_id: mainstream_browse_page.content_id

      expect(response.code).to eq('403')
    end

    it "allows only GDS Editors to republish mainstream browse pages" do
      stub_user.permissions << "GDS Editor"
      mainstream_browse_page = create(:mainstream_browse_page)
      allow(PublishingAPINotifier).to receive(:send_to_publishing_api)

      post :republish, tag_id: mainstream_browse_page.content_id

      expect(response.code).to eq('302')
    end

    it "allows non-GDS Editors to republish topic pages" do
      topic = create(:topic)
      allow(PublishingAPINotifier).to receive(:send_to_publishing_api)

      post :republish, tag_id: topic.content_id

      expect(response.code).to eq('302')
    end
  end
end
