require "rails_helper"

RSpec.describe ListItem do
  describe "#display_title" do
    it "shows the publishing-api title by default" do
      tag = create(:topic)
      publishing_api_has_linked_items(
        tag.content_id,
        items: [
          { base_path: "/some-link", title: "The Title" },
          { base_path: "/some-other-link", title: "Another Title" }
        ]
      )

      list_item = create(:list_item, base_path: "/some-link", list: create(:list, tag: tag))

      expect(list_item.display_title).to eql('The Title')
    end

    it "falls back to the cached title" do
      publishing_api_has_no_linked_items

      tag = create(:topic, slug: "my-tag-slug")
      list_item = create(:list_item, base_path: "/some-link", title: "My persisted title", list: create(:list, tag: tag))

      expect(list_item.display_title).to eql('My persisted title')
    end
  end
end
