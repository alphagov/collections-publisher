require "rails_helper"

RSpec.describe TagRepublisher do
  include ContentStoreHelpers

  describe "#republish_tags" do
    before do
      # Create a mainstream_browse_page, otherwise the publisher
      # cannot send the root pages.
      create(:mainstream_browse_page, :published, slug: "first-page")

      stub_content_store!
    end

    it "republishes given tags" do
      create(:mainstream_browse_page, :published, slug: "a-browse-page")
      TagRepublisher.new.republish_tags(Tag.all)
      expect(stubbed_content_store).to have_content_item_slug("/browse/a-browse-page")
    end

    it "republishes the browse index page" do
      TagRepublisher.new.republish_tags(Tag.all)
      expect(stubbed_content_store).to have_content_item_slug("/browse")
    end
  end
end
