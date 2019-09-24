require "rails_helper"

RSpec.describe TagAssociation do
  let!(:mainstream_browse_page_parent) { create(:mainstream_browse_page) }
  let!(:mainstream_browse_page)        { create(:mainstream_browse_page, parent: mainstream_browse_page_parent) }
  let!(:topic)                         { create(:topic) }

  it "should not allow associating topics on parent mainstream browse pages" do
    mainstream_browse_page_parent.topics << topic
    expect(mainstream_browse_page_parent.valid?).to eql false
  end

  it "is created by associating mainstream browse pages and topics" do
    expect(TagAssociation.where(from_tag: mainstream_browse_page,
                                to_tag: topic).size).to eq(0)

    mainstream_browse_page.topics << topic
    expect(mainstream_browse_page.save).to eql true

    expect(TagAssociation.where(from_tag: mainstream_browse_page,
                                to_tag: topic).size).to eq(1)
  end

  describe "cascade destroying associated topics" do
    it "destroys the topic associations when a topic page is destroyed" do
      mainstream_browse_page.topics << topic
      expect(mainstream_browse_page.save).to eql true

      expect(mainstream_browse_page.topics).to_not be_empty
      expect(topic.destroy).to be_truthy

      mainstream_browse_page.reload
      expect(mainstream_browse_page.topics).to be_empty
    end

    it "destroys the topic associations when a mainstream browse page is destroyed" do
      topic.mainstream_browse_pages << mainstream_browse_page
      expect(topic.save).to eql true

      expect(topic.mainstream_browse_pages).to_not be_empty
      expect(mainstream_browse_page.destroy).to be_truthy

      topic.reload
      expect(topic.mainstream_browse_pages).to be_empty
    end
  end
end
