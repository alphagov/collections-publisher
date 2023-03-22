require "rails_helper"
require "gds_api/test_helpers/content_store"

RSpec.describe TopicArchivalForm do
  include GdsApi::TestHelpers::ContentStore

  describe "#successor_path" do
    it "is not valid if the URL returns a 404 status code" do
      stub_content_store_does_not_have_item("/not-here")

      form = TopicArchivalForm.new(successor_path: "/not-here")

      expect(form.valid?).to eql(false)
    end

    it "is not valid if its not really a URL" do
      form = TopicArchivalForm.new(successor_path: "/i-Am Not A URL")

      expect(form.valid?).to eql(false)
    end

    it "is not valid if it does not start with a slash" do
      form = TopicArchivalForm.new(successor_path: "am-not-a-url")

      expect(form.valid?).to eql(false)
    end

    it "is valid if the URL returns 200" do
      stub_content_store_has_item("/existing-item")

      form = TopicArchivalForm.new(successor_path: "/existing-item")

      expect(form.valid?).to eql(true)
    end
  end
end
