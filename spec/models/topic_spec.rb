# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  slug        :string(255)      not null
#  title       :string(255)      not null
#  description :string(255)
#  parent_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#  content_id  :string(255)      not null
#  state       :string(255)      not null
#  dirty       :boolean          default(FALSE), not null
#  beta        :boolean          default(FALSE)
#
# Indexes
#
#  index_tags_on_content_id          (content_id) UNIQUE
#  index_tags_on_slug_and_parent_id  (slug,parent_id) UNIQUE
#  tags_parent_id_fk                 (parent_id)
#

require 'rails_helper'

RSpec.describe Topic do
  include ContentApiHelpers

  describe "lists association" do
    let(:topic) { create(:topic) }
    let!(:list1) { create(:list, :topic => topic) }
    let!(:list2) { create(:list, :topic => topic) }
    let!(:list3) { create(:list) }

    it "returns all lists for the topic" do
      expect(topic.lists).to match_array([list1, list2])
    end

    it "should efficiently traverse the relationships" do
      # Ensures that memoised values on the topic model are efficiently used.

      dereferenced_topic = topic.lists.first.topic
      expect(dereferenced_topic.object_id).to eq(topic.object_id)
    end

    it "deletes lists when the topic is deleted" do
      topic.destroy

      expect(List.find_by_id(list1.id)).not_to be
      expect(List.find_by_id(list2.id)).not_to be
      expect(List.find_by_id(list3.id)).to be
    end
  end

  describe '#uncategorized_list_items' do
    let(:topic) { create(:topic, :slug => 'topic') }
    let(:subtopic) { create(:topic, :parent => topic, :slug => 'subtopic') }

    it "returns ListItems for all content that's been tagged to the topic, but isn't in a list" do
      list1 = create(:list, :topic => subtopic)
      create(:list_item, :list => list1, :api_url => contentapi_url_for_slug('content-1'))
      list2 = create(:list, :topic => subtopic)
      create(:list_item, :list => list2, :api_url => contentapi_url_for_slug('content-3'))

      content_api_has_artefacts_with_a_tag('specialist_sector', 'topic/subtopic', [
        'content-1',
        'content-2',
        'content-3',
        'content-4',
      ])

      expect(subtopic.uncategorized_list_items.map(&:api_url)).to match_array([
        contentapi_url_for_slug('content-2'),
        contentapi_url_for_slug('content-4'),
      ])
    end
  end

  describe '#untagged_list_items' do
    let(:topic) { create(:topic, :slug => 'topic') }
    let(:subtopic) { create(:topic, :parent => topic, :slug => 'subtopic') }

    before :each do
      list1 = create(:list, :topic => subtopic)
      create(:list_item, :list => list1, :api_url => contentapi_url_for_slug('content-1'))
      create(:list_item, :list => list1, :api_url => contentapi_url_for_slug('content-2'))
      list2 = create(:list, :topic => subtopic)
      create(:list_item, :list => list2, :api_url => contentapi_url_for_slug('content-3'))
    end

    it "returns all list items for content that's no longer tagged to the topic" do
      content_api_has_artefacts_with_a_tag('specialist_sector', 'topic/subtopic', [
        'content-1',
        'content-3',
      ])

      expect(subtopic.untagged_list_items.map(&:api_url)).to eq([
        contentapi_url_for_slug('content-2'),
      ])
    end

    it "returns empty array if all list items' content is tagged to the topic" do
      content_api_has_artefacts_with_a_tag('specialist_sector', 'topic/subtopic', [
        'content-1',
        'content-2',
        'content-3',
      ])

      expect(subtopic.untagged_list_items.map(&:api_url)).to eq([])
    end
  end

  describe '#list_items_from_contentapi' do
    let(:topic) { create(:topic, :slug => 'topic') }
    let(:subtopic) { create(:topic, :parent => topic, :slug => 'subtopic') }

    it "returns the ListItem instances for all content tagged to the topic" do
      content_api_has_artefacts_with_a_tag('specialist_sector', 'topic/subtopic', [
        'example-content-1',
        'example-content-2'
      ])

      items = subtopic.list_items_from_contentapi

      expect(items.map(&:api_url)).to eq([
        contentapi_url_for_slug('example-content-1'),
        contentapi_url_for_slug('example-content-2'),
      ])
      expect(items.map(&:title)).to eq([
        "Example content 1",
        "Example content 2"
      ])
      expect(items.first).to be_a(ListItem)
    end

    it "returns empty array when no items are tagged to the topic" do
      content_api_has_artefacts_with_a_tag('specialist_sector', 'topic/subtopic', [])

      expect(subtopic.list_items_from_contentapi).to eq([])
    end

    it "returns empty array when no topic exists in content api" do
      stub_request(:get, %r[.]).to_return(status: 404)

      expect(subtopic.list_items_from_contentapi).to eq([])
    end
  end
end
