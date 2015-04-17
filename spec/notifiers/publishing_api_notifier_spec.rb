require "spec_helper"

RSpec.describe PublishingAPINotifier do
  let(:publishing_api) { double(:publishing_api, put_content_item: nil) }

  before do
    allow(CollectionsPublisher).to receive(:services).with(:publishing_api).and_return(publishing_api)
  end

  describe "#publish(sector_presenter)" do
    let(:sector_hash) { double(:sector_hash) }
    let(:base_path) { double(:base_path) }
    let(:presenter) { double(:sector_presenter, base_path: base_path, render_for_publishing_api: sector_hash) }

    it "sends a formatted version of the sector groupings to the publishing API" do
      PublishingAPINotifier.publish(presenter)

      expect(publishing_api).to have_received(:put_content_item).with(base_path, sector_hash)
    end
  end
end
