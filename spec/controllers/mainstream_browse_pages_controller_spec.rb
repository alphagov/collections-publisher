require 'rails_helper'

RSpec.describe MainstreamBrowsePagesController do

  let(:attributes) { attributes_for(:mainstream_browse_page) }
  let(:presenter) { double(:presenter, render_for_panopticon: nil) }

  before do
    stub_user.permissions << "GDS Editor"
  end

  describe 'GET new' do
    let(:browse_page) { create(:mainstream_browse_page) }

    it 'does not allow users without GDS Editor permissions access' do
      stub_user.permissions = ["signin"]

      get :new, parent_id: browse_page.id

      expect(response.status).to eq(403)
    end
  end

  describe 'POST create' do
    before do
      allow(MainstreamBrowsePagePresenter).to receive(:new)
        .and_return(presenter)
      allow(PublishingAPINotifier).to receive(:send_to_publishing_api)
    end

    it 'notifies panopticon' do
      expect(PanopticonNotifier).to receive(:create_tag).with(presenter)

      post :create, mainstream_browse_page: attributes
    end
  end

  describe 'PUT update' do
    before do
      allow(MainstreamBrowsePagePresenter).to receive(:new)
        .with(mainstream_browse_page).and_return(presenter)
      allow(PublishingAPINotifier).to receive(:send_to_publishing_api)
    end

    let(:mainstream_browse_page) {
      create(:mainstream_browse_page)
    }

    it 'notifies panopticon' do
      expect(PanopticonNotifier).to receive(:update_tag).with(presenter)

      put :update, id: mainstream_browse_page.content_id, mainstream_browse_page: attributes
    end
  end

end
