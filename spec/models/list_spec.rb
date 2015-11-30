require "rails_helper"

RSpec.describe List do
  describe "validations" do
    let(:list) { FactoryGirl.build(:list) }

    it "requires a tag" do
      list.tag = nil
      expect(list).not_to be_valid
    end
  end

  describe "#delete" do
    it "deletes list items" do
      list = create(:list)
      item = create(:list_item, list: list)

      list.delete

      expect { item.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#list_items_with_tagging_status" do
    it "returns the list items with tagged set to true if they're tagged" do
      list = create(:list, tag: create(:tag, slug: 'subtag'))
      create(:list_item, list: list, base_path: '/tagged-item')
      create(:list_item, list: list, base_path: '/untagged-item')
      stub_any_call_to_rummager_with_documents([{ link: '/tagged-item' }])

      list_item = list.list_items_with_tagging_status.first

      expect(list_item.tagged?).to eql(true)
    end

    it "returns the list items with tagged set to false if they're not tagged" do
      list = create(:list, tag: create(:tag, slug: 'subtag'))
      create(:list_item, list: list, base_path: '/untagged-item')
      stub_any_call_to_rummager_with_documents([])

      list_item = list.list_items_with_tagging_status.first

      expect(list_item.tagged?).to eql(false)
    end
  end
end
