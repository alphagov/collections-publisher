require "rails_helper"

RSpec.describe TaggedDocuments do
  describe "#documents" do
    it "returns empty array for mainstream browse pages that have no documents tagged to them" do
      mainstream_browse_page = create(:mainstream_browse_page, slug: "a-child", parent: create(:mainstream_browse_page, slug: "a-parent"))

      publishing_api_has_linked_items(
        mainstream_browse_page.content_id,
        items: [],
      )

      documents = TaggedDocuments.new(mainstream_browse_page).documents

      expect(documents).to eql([])
    end

    it "returns the documents tagged to a mainstream-browse-page" do
      mainstream_browse_page = create(:mainstream_browse_page, slug: "a-child", parent: create(:mainstream_browse_page, slug: "a-parent"))

      publishing_api_has_linked_items(
        mainstream_browse_page.content_id,
        items: [{ base_path: "/some-link", title: "The Title" }, { base_path: "/some-other-link", title: "Another Title" }],
      )

      documents = TaggedDocuments.new(mainstream_browse_page).documents

      expect(documents.size).to eql(2)
    end

    it "returns turns the results into document classes" do
      mainstream_browse_page = create(:mainstream_browse_page, slug: "a-child", parent: create(:mainstream_browse_page, slug: "a-parent"))

      publishing_api_has_linked_items(
        mainstream_browse_page.content_id,
        items: [{ base_path: "/some-link", title: "The Title" }],
      )

      document = TaggedDocuments.new(mainstream_browse_page).documents.first

      expect(document.title).to eql("The Title")
      expect(document.base_path).to eql("/some-link")
    end
  end
end
