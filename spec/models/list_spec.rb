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
    include ContentApiHelpers

    it "returns the list items with tagged set to true if they're tagged" do
      list = create(:list, tag: create(:tag, slug: 'subtag'))
      tagged = create(:list_item, list: list, base_path: '/tagged-item')
      not_tagged = create(:list_item, list: list, base_path: '/untagged-item')
      content_api_has_artefacts_with_a_tag('tag', 'subtag', ['tagged-item'])

      list_item = list.list_items_with_tagging_status.first

      expect(list_item.tagged?).to eql(true)
    end

    it "returns the list items with tagged set to false if they're not tagged" do
      list = create(:list, tag: create(:tag, slug: 'subtag'))
      not_tagged = create(:list_item, list: list, base_path: '/untagged-item')
      content_api_has_artefacts_with_a_tag('tag', 'subtag', [])

      list_item = list.list_items_with_tagging_status.first

      expect(list_item.tagged?).to eql(false)
    end
  end
end
