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
#
# Indexes
#
#  index_tags_on_slug_and_parent_id  (slug,parent_id) UNIQUE
#

require 'spec_helper'

RSpec.describe Topic do

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
end
