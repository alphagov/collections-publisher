require "rails_helper"

RSpec.describe ListItem do
  describe "#display_title" do
    it "shows the rummager title by default" do
      stub_any_call_to_rummager_with_documents([{ link: "/some-link", title: "The Title" },
                                                { link: "/some-other-link", title: "Another Title" }])

      tag = create(:topic)
      list_item = create(:list_item, base_path: "/some-link", list: create(:list, tag: tag))

      expect(list_item.display_title).to eql('The Title')
    end

    it "falls back to the cached title" do
      stub_any_call_to_rummager_with_no_documents

      tag = create(:topic, slug: "my-tag-slug")
      list_item = create(:list_item, base_path: "/some-link", title: "My persisted title", list: create(:list, tag: tag))

      expect(list_item.display_title).to eql('My persisted title')
    end
  end
end