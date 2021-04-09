require "rails_helper"

RSpec.describe Coronavirus::SubSection::StructuredContent do
  let(:content) { "###title \n [test](/coronavirus)" }

  describe "#parseable?" do
    it "returns true if content is valid" do
      expect(described_class.parseable?(content)).to be true
    end

    it "returns false if hashes are missing from title" do
      content = "title \n [test](/coronavirus)"
      expect(described_class.parseable?(content)).to be false
    end

    it "returns false if a link is malformed" do
      content = "###title \n [test](/coronavirus"
      expect(described_class.parseable?(content)).to be false
    end

    it "returns false if there's a plaintext line in content" do
      content = "###title \n [test](/coronavirus) \n plan text \n [another](/link)"
      expect(described_class.parseable?(content)).to be false
    end
  end

  describe "#parse" do
    let(:parsed_content) { described_class.parse(content) }
    it "converts a valid content string into a list of headers and links" do
      expected_output = [
        Coronavirus::SubSection::StructuredContent::Header.new("title"),
        Coronavirus::SubSection::StructuredContent::Link.new("test", "/coronavirus"),
      ]
      expect(parsed_content.items).to eq(expected_output)
    end
  end

  describe "#error_lines" do
    it "returns an empty array for valid content" do
      expect(described_class.error_lines(content)).to eq([])
    end

    it "returns an error when the header is wrong" do
      content = "title \n [test](/coronavirus)"
      expect(described_class.error_lines(content)).to eq(%w[title])
    end

    it "returns an error when a link is malformed" do
      content = "###title \n [test](/coronavirus"
      expect(described_class.error_lines(content)).to eq(%w[[test](/coronavirus])
    end

    it "can return multiple errors" do
      content = "title \n [test](/coronavirus"
      expect(described_class.error_lines(content).length).to eq(2)
    end
  end

  describe "#links" do
    it "only returns the link objects" do
      links = described_class.parse(content).links
      expected_output = [Coronavirus::SubSection::StructuredContent::Link.new("test", "/coronavirus")]
      expect(links).to eq(expected_output)
    end
  end
end
