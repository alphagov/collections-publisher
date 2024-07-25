require "rails_helper"

RSpec.describe List do
  describe "validations" do
    let(:list) { FactoryBot.build(:list) }

    it "requires a tag" do
      list.tag = nil
      expect(list).not_to be_valid
    end

    it "requires a name" do
      list.name = nil
      expect(list).not_to be_valid
    end
  end

  describe "#delete" do
    it "deletes list items" do
      list = create(:list)
      item = create(:list_item, list:)

      list.delete

      expect { item.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#list_items_with_tagging_status" do
    it "returns the list items with tagged set to true if they're tagged" do
      list = create(:list, tag: create(:tag, slug: "subtag"))
      create(:list_item, list:, content_id: "123")
      create(:list_item, list:, content_id: "456")
      publishing_api_has_linked_items(list.tag.content_id, items: [{ content_id: "123" }])

      list_item = list.list_items_with_tagging_status.first

      expect(list_item.tagged?).to eql(true)
    end

    it "returns the list items with tagged set to false if they're not tagged" do
      list = create(:list, tag: create(:tag, slug: "subtag"))
      create(:list_item, list:, content_id: "456")
      publishing_api_has_no_linked_items

      list_item = list.list_items_with_tagging_status.first

      expect(list_item.tagged?).to eql(false)
    end
  end

  describe "#available_list_items" do
    it "returns tagged list items from the publishing api that are in the list" do
      list = create(:list)
      create(:list_item, list:, content_id: "123")
      publishing_api_has_linked_items(
        list.tag.content_id,
        items: [
          { base_path: "/item-in-list", title: "Item in list", content_id: "123" },
          { base_path: "/item-not-in-list", title: "Item not in list", content_id: "456" },
        ],
      )

      expect(list.available_list_items.count).to eq 1
      expect(list.available_list_items.first.base_path).to eq "/item-not-in-list"
      expect(list.available_list_items.first.title).to eq "Item not in list"
      expect(list.available_list_items.first.content_id).to eq "456"
    end
  end
end
