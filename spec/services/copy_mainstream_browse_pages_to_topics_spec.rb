require "rails_helper"

RSpec.describe CopyMainstreamBrowsePageToTopic do
  include GdsApi::TestHelpers::PublishingApi
  # parent, active_top_level_browse_page, top_level_browse_pages
  let!(:parent) do
    create(:mainstream_browse_page, :published,
           title: "Disabled people",
           slug: "disabilities",
           parent_id: nil,
           children: [])
  end

  # top_level_browse_pages
  let(:top_level_browse_page) do
    create(:mainstream_browse_page, :published,
           title: "Business and self-employed",
           slug: "business")
  end

  # second_level_browse_pages - includes itself
  let(:sibling1) do
    create(:mainstream_browse_page, :published,
           title: "Benefits and financial help",
           slug: "benefits")
  end
  let(:sibling2) do
    create(:mainstream_browse_page, :published,
           title: "Disability equipment and transport",
           slug: "equipment")
  end

  # let(:child_page) do
  #   allow(Services.publishing_api).to receive(:lookup_content_id).and_return(nil)
  #   page = create(:published_step_by_step_page)
  #   # .and_return( {page.base_path => page.content_id})
  # end

  let(:mainstream_browse_page) do
    create(:mainstream_browse_page, :published,
           title: "Carers",
           slug: "carers",
           parent_id: parent.id)
  end

  before do
    # Docs: https://github.com/alphagov/gds-api-adapters/blob/master/lib/gds_api/test_helpers/publishing_api.rb
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  describe ".call" do
    it "saves the Topic" do
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

    it "saves the parent and child associations for legacy Mainstream Browse Page" do
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

    it "flags that the Topic used to be a Mainstream Browse Page" do
      described_class.call([mainstream_browse_page])
      topic = Topic.find_by(title: "Carers")

      assert_publishing_api_put_content(
        topic.content_id,
        request_json_includes(
          "details": {
            "groups": [],
            "internal_name": "Carers",
            "mainstream_browse_type": true,
          },
        ),
      )
    end
  end
end
