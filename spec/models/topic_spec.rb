require "rails_helper"

RSpec.describe Topic do
  describe "#base_path" do
    it "includes the /topic namespace for parents" do
      topic = create(:topic, slug: "foo")

      base_path = topic.base_path

      expect(base_path).to eql("/topic/foo")
    end

    it "includes the /topic namespace for subtopics" do
      topic = create(:topic, slug: "bar", parent: create(:topic, slug: "foo"))

      base_path = topic.base_path

      expect(base_path).to eql("/topic/foo/bar")
    end
  end

  describe "#can_be_archived?" do
    it "returns true for published level two topic" do
      topic = create(:topic, :published, parent: create(:topic))

      expect(topic.can_be_archived?).to eql(true)
    end

    it "returns false for draft level two topic" do
      topic = create(:topic, :draft, parent: create(:topic))

      expect(topic.can_be_archived?).to eql(false)
    end

    it "returns false for archived level two topic" do
      topic = create(:topic, :archived, parent: create(:topic))

      expect(topic.can_be_archived?).to eql(false)
    end

    it "returns false for level one topic" do
      topic = create(:topic, :published, parent: nil)

      expect(topic.can_be_archived?).to eql(false)
    end
  end

  describe "#subscriber_list_search_attributes" do
    it "returns search attributes to search subscriber list for the topic" do
      content_id = SecureRandom.uuid
      topic = create(:topic, content_id: content_id)

      subscriber_list_search_attributes = topic.subscriber_list_search_attributes

      expect(subscriber_list_search_attributes).to eql({ "links" => { topics: [topic.content_id] } })
    end
  end
end
