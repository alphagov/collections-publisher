require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.describe "ContentItem" do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::ContentItemHelpers

  let(:base_path) { "/redirect-to-me" }
  let(:content_item_data) { content_item_for_base_path(base_path) }

  describe ".find!" do
    it "creates the content item" do
      stub_content_store_has_item(base_path, content_item_data)

      expect(ContentItem.find!(base_path).data).to eq content_item_data
    end
  end

  describe "#base_path" do
    it "returns the base path" do
      content_item = ContentItem.new(content_item_data)
      expect(content_item.base_path).to eq base_path
    end
  end

  describe "#subroutes" do
    it "returns an empty array" do
      content_item = ContentItem.new(content_item_data)

      expect(content_item.subroutes).to eq []
    end
  end
end
