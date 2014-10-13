require 'spec_helper'

describe MainstreamBrowsePagesController do

  let(:attributes) { attributes_for(:mainstream_browse_page) }
  let(:presenter) { double(:presenter, render_for_panopticon: nil) }

  before do
    allow(controller).to receive(:mainstream_browse_page)
      .and_return(mainstream_browse_page) # defined in `describe` blocks below
    allow(MainstreamBrowsePagePresenter).to receive(:new)
      .with(mainstream_browse_page).and_return(presenter)
  end

  describe 'POST create' do
    let(:mainstream_browse_page) { double(:mainstream_browse_page,
      :attributes= => true, # stub assignment from decent_exposure
      :save => true
    )}

    it 'notifies panopticon' do
      expect(PanopticonNotifier).to receive(:create_tag).with(presenter)

      post :create, mainstream_browse_page: attributes
    end
  end

  describe 'PUT update' do
    let(:mainstream_browse_page) {
      double(:mainstream_browse_page, update_attributes: true)
    }

    it 'notifies panopticon' do
      expect(PanopticonNotifier).to receive(:update_tag).with(presenter)

      put :update, id: 'abc', mainstream_browse_page: attributes
    end
  end

end
