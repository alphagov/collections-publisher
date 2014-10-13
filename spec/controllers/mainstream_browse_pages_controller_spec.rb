require 'spec_helper'

describe MainstreamBrowsePagesController do

  describe 'POST create' do
    let(:attributes) { attributes_for(:mainstream_browse_page) }

    let(:presenter) { double(:presenter, render_for_panopticon: nil) }
    let(:mainstream_browse_page) { double(:mainstream_browse_page,
      :attributes= => true, # stub assignment from decent_exposure
      :save => true
    )}

    it 'notifies panopticon' do
      allow(MainstreamBrowsePage).to receive(:new)
        .and_return(mainstream_browse_page)
      allow(MainstreamBrowsePagePresenter).to receive(:new)
        .with(mainstream_browse_page).and_return(presenter)

      expect(PanopticonNotifier).to receive(:create_tag).with(presenter)

      post :create, mainstream_browse_page: attributes
    end
  end

end
