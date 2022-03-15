require "rails_helper"

RSpec.describe CopyMainstreamBrowsePagesToTopics do
  include GdsApi::TestHelpers::PublishingApi

  let!(:parent) do
    create(:mainstream_browse_page, :published,
           title: "Disabled people",
           slug: "disabilities",
           parent_id: nil,
           children: [])
  end

  let(:mainstream_browse_page) do
    create(:mainstream_browse_page, :published,
           title: "Carers",
           slug: "carers",
           parent_id: parent.id)
  end

  before do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
  end

  describe ".call" do
    it "saves a copy of Mainstream Browse Page as a Topic" do
      publishing_api_has_no_linked_items

      described_class.call([mainstream_browse_page])
      topic = Topic.find_by(title: "Carers")

      expect(topic.type).to eq("Topic")
      expect(topic.slug).to eq("carers-mainstream-copy")

      assert_publishing_api_put_content(
        topic.content_id,
        request_json_includes({
          "title" => "Carers",
          "base_path": "/topic/carers-mainstream-copy",
          "document_type" => "topic",
          "schema_name": "topic",
        }),
      )
    end
  end
end
