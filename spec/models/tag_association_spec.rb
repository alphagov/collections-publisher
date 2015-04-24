# == Schema Information
#
# Table name: tag_associations
#
#  id          :integer          not null, primary key
#  from_tag_id :integer          not null
#  to_tag_id   :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_tag_associations_on_from_tag_id_and_to_tag_id  (from_tag_id,to_tag_id) UNIQUE
#  index_tag_associations_on_to_tag_id                  (to_tag_id)
#

require 'spec_helper'

describe TagAssociation do
  let!(:mainstream_browse_page) { create(:mainstream_browse_page) }
  let!(:topic)                  { create(:topic) }

  it "is created by associating mainstream browse pages and topics" do
    expect(TagAssociation.where(from_tag: mainstream_browse_page,
                                to_tag: topic).size).to eq(0)

    mainstream_browse_page.topics << topic
    expect(mainstream_browse_page.save).to be_true

    expect(TagAssociation.where(from_tag: mainstream_browse_page,
                                to_tag: topic).size).to eq(1)
  end

  describe "cascade destroying associated topics" do
    it "destroys the topic associations when a topic page is destroyed" do
      mainstream_browse_page.topics << topic
      expect(mainstream_browse_page.save).to be_true

      expect(mainstream_browse_page.topics).to_not be_empty
      expect(topic.destroy).to be_true

      mainstream_browse_page.reload
      expect(mainstream_browse_page.topics).to be_empty
    end

    it "destroys the topic associations when a mainstream browse page is destroyed" do
      topic.mainstream_browse_pages << mainstream_browse_page
      expect(topic.save).to be_true

      expect(topic.mainstream_browse_pages).to_not be_empty
      expect(mainstream_browse_page.destroy).to be_true

      topic.reload
      expect(topic.mainstream_browse_pages).to be_empty
    end
  end
end
