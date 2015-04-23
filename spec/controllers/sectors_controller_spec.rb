require "spec_helper"

RSpec.describe SectorsController do

  describe "#publish" do
    let(:topic) { create(:topic) }
    let(:subtopic) { create(:topic, :parent => topic) }
    let(:presenter) { double(:presenter, render_for_publishing_api: nil) }

    before do
      allow(SectorPresenter).to receive(:new).with(subtopic).and_return(presenter)
      allow(PublishingAPINotifier).to receive(:publish).with(presenter).and_return(true)
    end

    it "notifies the publishing API" do
      expect(PublishingAPINotifier).to receive(:publish).with(presenter)

      put :publish, sector_id: subtopic.panopticon_slug
    end

    it "marks the sector as published" do
      put :publish, sector_id: subtopic.panopticon_slug

      subtopic.reload
      expect(subtopic).not_to be_dirty
    end
  end
end
