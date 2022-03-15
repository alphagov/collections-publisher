require "rails_helper"

RSpec.describe CopyMainstreamBrowsePageToTopic do
  include GdsApi::TestHelpers::PublishingApi
  # parent, active_top_level_browse_page, top_level_browse_pages
  let(:parent) {
    create(:mainstream_browse_page, :published,
           title: "Disabled people",
           slug: "disabilities")
  }

  # top_level_browse_pages
  let(:top_level_browse_page) {
    create(:mainstream_browse_page, :published,
           title: "Business and self-employed",
           slug: "business")
  }

  # second_level_browse_pages - includes itself
  let(:sibling1) {
    create(:mainstream_browse_page, :published,
           title: "Benefits and financial help",
           slug: "disabilities/benefits")
  }
  let(:sibling2) {
    create(:mainstream_browse_page, :published,
           title: "Disability equipment and transport",
           slug: "disabilities/equipment")
  }

  let(:mainstream_browse_page) do
    create(:mainstream_browse_page, :published,
           title: "Carers",
           slug: "carers")
  end

  before do
    # Docs: https://github.com/alphagov/gds-api-adapters/blob/master/lib/gds_api/test_helpers/publishing_api.rb
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    mainstream_browse_page.parent = parent
  end

  describe ".call" do
    it "saves the Topic" do
      described_class.call(mainstream_browse_page)
      topic = Topic.find_by(title: "Carers")

      expect(topic.type).to eq("Topic")
      expect(topic.slug).to eq("carers-copy")

      pp topic.dependent_tags
      pp topic.parent
      pp topic.children

      assert_publishing_api_put_content(
        topic.content_id,
        request_json_includes({
          "title" => "Carers",
          "base_path": "/topic/carers-copy",
          "document_type" => "topic",
          "schema_name": "topic",
        }),
      )
    end

    fit "saves the links" do
      described_class.call(mainstream_browse_page)
      topic = Topic.find_by(title: "Carers")

      expect(topic.type).to eq("Topic")
      expect(topic.slug).to eq("carers-copy")

      assert_publishing_api_put_content(
        topic.content_id,
        request_json_includes({
          "title" => "Carers",
          "document_type" => "topic",
          "schema_name": "topic",
        }),
      )
    end

    it "flags that the Topic used to be a Mainstream Browse Page" do
      described_class.call(mainstream_browse_page)

      topic = Topic.find_by(title: "Carers")
      # content_id = extract_content_id_from(topic.base_path)
      assert_publishing_api_put_content(
        topic.content_id,
        request_json_includes(
          "details" => {
            "mainstream_browse_copy" => "true",
          },
        ),
      )
    end
  end
end
