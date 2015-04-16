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

require 'spec_helper'

describe TagAssociation do
  it "is created by associating mainstream browse pages and topics" do
    expect(TagAssociation.all.size).to eq(0)

    mainstream_browse_page = MainstreamBrowsePage.new(
      slug: "housing", title: "Housing", description: "All about housing")
    expect(mainstream_browse_page.save).to be_true

    topic = Topic.new(
      slug: "gas", title: "Gas", description: "All about gas safety")
    expect(topic.save).to be_true

    expect(TagAssociation.where(from_tag: mainstream_browse_page,
                                to_tag: topic).size).to eq(0)

    mainstream_browse_page.topics << topic
    expect(mainstream_browse_page.save).to be_true

    expect(TagAssociation.where(from_tag: mainstream_browse_page,
                                to_tag: topic).size).to eq(1)
  end
end
