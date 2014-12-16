require 'spec_helper'

describe MainstreamBrowsePagesController do

  let(:attributes) { attributes_for(:mainstream_browse_page) }
  let(:presenter) { double(:presenter, render_for_panopticon: nil) }

  describe 'GET new' do
    let(:parent_browse_page) { create(:mainstream_browse_page) }

    it 'finds a parent tag given the parent_id parameter' do
      get :new, parent_id: parent_browse_page.id

      # parent is a private method exposed to the view through the helper_method
      # behaviour. we can't call `controller.parent` direcly here, so we have
      # to use the `send` method.
      #
      parent = controller.send(:parent)

      expect(parent).to eq(parent_browse_page)
    end

    it 'finds a parent tag given the mainstream_browse_page[parent_id] parameter' do
      get :new, mainstream_browse_page: { parent_id: parent_browse_page.id }

      # see note in previous test around use of `send` here
      parent = controller.send(:parent)

      expect(parent).to eq(parent_browse_page)
    end
  end

  describe 'POST create' do
    before do
      allow(controller).to receive(:resource)
        .and_return(mainstream_browse_page) # defined in `describe` blocks below
      allow(MainstreamBrowsePagePresenter).to receive(:new)
        .with(mainstream_browse_page).and_return(presenter)
    end

    let(:mainstream_browse_page) {
      MainstreamBrowsePage.new
    }

    it 'notifies panopticon' do
      expect(PanopticonNotifier).to receive(:create_tag).with(presenter)

      post :create, mainstream_browse_page: attributes
    end
  end

  describe 'PUT update' do
    before do
      allow(controller).to receive(:resource)
        .and_return(mainstream_browse_page) # defined in `describe` blocks below
      allow(MainstreamBrowsePagePresenter).to receive(:new)
        .with(mainstream_browse_page).and_return(presenter)
    end

    let(:mainstream_browse_page) {
      create(:mainstream_browse_page)
    }

    it 'notifies panopticon' do
      expect(PanopticonNotifier).to receive(:update_tag).with(presenter)

      put :update, id: 'abc', mainstream_browse_page: attributes
    end
  end

end
