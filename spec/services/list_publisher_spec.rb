require "rails_helper"

RSpec.describe ListPublisher do
  describe "#perform" do
    before { allow(PublishingAPINotifier).to receive(:notify) }

    it "updates the groups-data to be sent to the content store" do
      mainstream_browse_page = create(:mainstream_browse_page)
      create(:list, name: "A Listname", tag: mainstream_browse_page)

      ListPublisher.new(mainstream_browse_page).perform

      expect(mainstream_browse_page.published_groups).to eql([{ "name" => "A Listname", "content_ids" => [] }])
    end

    it "sends the updated information to the content-store" do
      mainstream_browse_page = create(:mainstream_browse_page)

      ListPublisher.new(mainstream_browse_page).perform

      expect(PublishingAPINotifier).to have_received(:notify)
    end

    it "clears the dirty flag from tag" do
      mainstream_browse_page = create(:mainstream_browse_page, dirty: true)

      ListPublisher.new(mainstream_browse_page).perform

      expect(mainstream_browse_page).not_to be_dirty
    end
  end
end
