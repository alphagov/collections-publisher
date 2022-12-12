require "rails_helper"

RSpec.describe ListRepublisher do
  describe "#republish_tags" do
    let(:mainstream_browse_page) { create(:mainstream_browse_page, :published, child_ordering: "curated") }
    let(:list_item) { create(:list_item) }
    let!(:list) { create(:list, tag: mainstream_browse_page, list_items: [list_item]) }

    before do
      stub_any_publishing_api_put_content
      stub_any_publishing_api_publish
      stub_any_publishing_api_patch_links

      allow(Services.publishing_api).to receive(:get_linked_items).with(
        mainstream_browse_page.content_id,
        hash_including(link_type: :mainstream_browse_pages),
      ).and_call_original

      stub_publishing_api_has_linked_items(
        [
          { base_path: list_item.base_path, title: list_item.title, content_id: "f508898d-1ba0-46f7-b150-828166886d97" },
        ],
        {
          content_id: mainstream_browse_page.content_id,
          link_type: "mainstream_browse_pages",
          fields: %i[title base_path content_id],
        },
      )
      allow(Services.publishing_api).to receive(:get_linked_items).with(
        mainstream_browse_page.content_id,
        hash_including(link_type: :topics),
      ).and_return(
        [{ "title" => list_item.title,
           "base_path" => list_item.base_path,
           "content_id" => list_item.content_id }],
      )
    end

    it "republishes given tags with lists/groups" do
      described_class.new.republish_tags(Tag.all)

      mainstream_browse_page.reload
      expect(mainstream_browse_page.published_groups).to eq([{
        "content_ids" => [list_item.content_id], "name" => list.name
      }])
      assert_publishing_api_put_content(
        mainstream_browse_page.content_id,
        request_json_includes(
          "details": {
            "groups": [
              {
                "name": list.name,
                "content_ids": [list_item.content_id],
              },
            ],
            "internal_name": mainstream_browse_page.title,
            "second_level_ordering": mainstream_browse_page.child_ordering,
            "ordered_second_level_browse_pages": [],
          },
        ),
      )
    end

    it "skips tags without lists/groups" do
      a_to_z_mainstream_browse = create(:mainstream_browse_page, :published, lists: [])

      described_class.new.republish_tags(Tag.all)

      expect(TagPresenter).not_to receive(:presenter_for).with(a_to_z_mainstream_browse)
    end
  end
end
