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
end
