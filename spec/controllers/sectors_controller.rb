require "spec_helper"
require 'gds_api/test_helpers/content_api'

RSpec.describe SectorsController do
  include GdsApi::TestHelpers::ContentApi

  describe "#publish" do
    let(:lists) {
      [
        FactoryGirl.create(:list, dirty: true),
        FactoryGirl.create(:list, dirty: false)
      ]
    }
    let(:sector) { double(:sector, lists: lists) }
    let(:presenter) { double(:presenter, render_for_publishing_api: nil) }

    before do
      content_api_has_sorted_tags('specialist_sector', 'alphabetical', [{
        slug: 'oil-and-gas/offshore',
        title: 'Offshore',
        parent: {
          slug: 'oil-and-gas',
          title: 'Oil and Gas'
        }
      }])

      allow(Sector).to receive(:find).with('oil-and-gas/offshore').and_return(sector)
      allow(SectorPresenter).to receive(:new).with(sector).and_return(presenter)
      allow(PublishingAPINotifier).to receive(:publish).with(presenter).and_return(true)
    end

    it "notifies the publishing API" do
      expect(PublishingAPINotifier).to receive(:publish).with(presenter)

      put :publish, sector_id: 'oil-and-gas/offshore'
    end

    it "marks the sector as published" do
      put :publish, sector_id: 'oil-and-gas/offshore'

      # We currently use lists for persistence of sector publish state.
      # This will change when we move tags over from Panopticon.
      lists.each do |list|
        list.reload
        expect(list).not_to be_dirty
      end
    end
  end
end
