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
    stub_any_publishing_api_patch_links
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

    it "flags that the Topic used to be a Mainstream Browse Page" do
      publishing_api_has_no_linked_items

      described_class.call([mainstream_browse_page])
      topic = Topic.find_by(title: "Carers")

      assert_publishing_api_put_content(
        topic.content_id,
        request_json_includes(
          "details": {
            "groups": [],
            "internal_name": "Carers",
            "mainstream_browse_origin": mainstream_browse_page.content_id,
          },
        ),
      )
    end

    it "saves the parent and child associations between the new Topics" do
      publishing_api_has_no_linked_items

      described_class.call([parent, mainstream_browse_page])
      parent_topic = Topic.find_by(title: "Disabled people")
      topic = Topic.find_by(title: "Carers")

      expect(topic.parent).to eq(parent_topic)
      expect(parent_topic.parent).to eq(nil)
      expect(parent_topic.children).to eq([topic])

      assert_publishing_api_patch_links(
        topic.content_id,
        links: {
          parent: [parent_topic.content_id],
          primary_publishing_organisation: [RootTopicPresenter::GDS_CONTENT_ID],
        },
      )

      assert_publishing_api_patch_links(
        parent_topic.content_id,
        links: {
          children: [topic.content_id],
          primary_publishing_organisation: [RootTopicPresenter::GDS_CONTENT_ID],
        },
      )
    end
  end
end
