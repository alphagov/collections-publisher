require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.describe EmailAlerts::EmailAlertsApiParamsHelper do
  include GdsApi::TestHelpers::ContentStore
  include EmailAlerts::EmailAlertsApiParamsHelper

  describe "document_collection_subscriber_list_params" do
    let(:content_id) { "448fd2de-fb0d-11ed-be56-0242ac120002" }
    let(:content_item_data) do
      content_item_for_base_path("/base-path").merge({ "content_id" => content_id })
    end

    let(:list_params) do
      {
        "url" => content_item_data["base_path"],
        "title" => content_item_data["title"],
        "content_id" => content_item_data["content_id"],
        "description" => content_item_data["description"],
      }
    end

    context "content is a document collection" do
      it "adds a reverse link to the params" do
        content_item_data.merge!("document_type" => "document_collection")
        expected_list_params = list_params.merge("links" => { "document_collections" => [content_id] })

        expect(document_collection_subscriber_list_params(ContentItem.new(content_item_data))).to match(expected_list_params)
      end
    end
  end

  describe "specialist_topic_subscriber_list_params" do
    it "delegates to the topic's subscriber list search attributes" do
      topic = instance_double(Topic)

      expect(topic).to receive(:subscriber_list_search_attributes)

      specialist_topic_subscriber_list_params(topic)
    end
  end
end
