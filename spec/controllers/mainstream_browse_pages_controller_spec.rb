require 'rails_helper'

RSpec.describe MainstreamBrowsePagesController do
  let(:attributes) { attributes_for(:mainstream_browse_page) }
  let(:presenter) { double(:presenter) }

  before do
    stub_user.permissions << "GDS Editor"
  end

  describe 'GET new' do
    let(:browse_page) { create(:mainstream_browse_page) }

    it 'does not allow users without GDS Editor permissions access' do
      stub_user.permissions = %w(signin)

      get :new, params: { parent_id: browse_page.id }

      expect(response.status).to eq(403)
    end
  end

  describe 'PUT update' do
    before do
      allow(MainstreamBrowsePagePresenter).to receive(:new)
        .with(mainstream_browse_page).and_return(presenter)
      allow(PublishingAPINotifier).to receive(:notify)
    end

    let(:mainstream_browse_page) {
      create(:mainstream_browse_page)
    }
  end
end
