require "rails_helper"

RSpec.describe MarkdownService do
  describe "#strip_markdown" do
    it "removes markdown from link" do
      content = "Here is a [link to something](/foo) and here is a [link to something else](/bar)"
      expected = "Here is a link to something and here is a link to something else"

      expect(described_class.new.strip_markdown(content)).to eq(expected)
    end
  end
end
