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

  describe "#subscriber_list_search_attributes" do
    it "returns search attributes to search subscriber list for the topic" do
      content_id = SecureRandom.uuid
      topic = create(:topic, content_id: content_id)

      subscriber_list_search_attributes = topic.subscriber_list_search_attributes

      expect(subscriber_list_search_attributes).to eql({ "links" => { topics: [topic.content_id] } })
    end
  end
end
