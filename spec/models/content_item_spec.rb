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

  describe "#mapped_specialist_topic_content_id" do
    let(:mapped_specialist_topic_content_id) { "e33474e6-0448-11ee-be56-0242ac120002" }

    it "returns the mapped specialist topic content id" do
      content_item_data_with_mapped_specialist_topic = content_item_data.merge(
        { "details" => { "mapped_specialist_topic_content_id" => mapped_specialist_topic_content_id } },
      )

      content_item = ContentItem.new(content_item_data_with_mapped_specialist_topic)

      expect(content_item.mapped_specialist_topic_content_id).to eq mapped_specialist_topic_content_id
    end
  end

  describe "#subroutes" do
    it "returns an empty array" do
      content_item = ContentItem.new(content_item_data)

      expect(content_item.subroutes).to eq []
    end
  end
end
