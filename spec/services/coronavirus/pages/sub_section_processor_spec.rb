require "rails_helper"

RSpec.describe Coronavirus::Pages::SubSectionProcessor do
  describe ".call" do
    it "converts a sub_section data into a block of markdown" do
      sub_section_payload_data = [
        {
          "title" => "Title",
          "list" => [
            {
              "label" => "Label",
              "url" => "/path",
            },
          ],
        },
        {
          "title" => "Another Title",
          "list" => [
            {
              "label" => "Another Label",
              "url" => "/another-path",
            },
          ],
        },
      ]

      output = described_class.call(sub_section_payload_data)
      lines = output[:content].split("\n")

      expect(lines.count).to eq(4)
      expect(lines).to eq([
        "###Title",
        "[Label](/path)",
        "###Another Title",
        "[Another Label](/another-path)",
      ])
    end

    it "doesn't add featured links to the lines of content" do
      sub_section_payload_data = [
        {
          "title" => "Title",
          "list" => [
            {
              "label" => "Label",
              "url" => "/path",
              "featured_link" => true,
              "description" => "description",
            },
            {
              "label" => "Another label",
              "url" => "/another-path",
            },
          ],
        },
      ]

      output = described_class.call(sub_section_payload_data)
      lines = output[:content].split("\n")

      expect(lines.count).to eq(2)
      expect(lines).to eq(["###Title", "[Another label](/another-path)"])
    end

    it "adds the title as the first line" do
      title = Faker::Lorem.sentence
      sub_section_payload_data = [
        {
          "title" => title,
          "list" => [],
        },
      ]

      output = described_class.call(sub_section_payload_data)
      lines = output[:content].split("\n")

      expect(lines.first).to eq "####{title}"
    end

    it "adds the first link as the first line if the title is blank" do
      label = Faker::Lorem.sentence
      url = "/#{File.join(Faker::Lorem.words)}"

      sub_section_payload_data = [
        {
          "title" => nil,
          "list" => [
            {
              "label" => label,
              "url" => url,
            },
          ],
        },
      ]

      output = described_class.call(sub_section_payload_data)
      lines = output[:content].split("\n")

      expect(lines.first).to eq "[#{label}](#{url})"
    end

    it "stores the url, label and description in the appropriate action_link fields" do
      url = "/#{File.join(Faker::Lorem.words)}"
      label = Faker::Lorem.sentence
      description = Faker::Lorem.sentence

      sub_section_payload_data = [
        {
          "title" => nil,
          "list" => [
            {
              "label" => label,
              "url" => url,
              "featured_link" => true,
              "description" => description,
            },
          ],
        },
      ]

      output = described_class.call(sub_section_payload_data)

      expect(output).to match hash_including(
        action_link_url: url,
        action_link_content: label,
        action_link_summary: description,
      )
    end

    it "removes any priority-taxons query parameters from links" do
      url = "/#{File.join(Faker::Lorem.words)}"
      query_string = "?priority-taxon=774cee22-d896-44c1-a611-e3109cce8eae"
      url_with_querystring = "#{url}#{query_string}"
      label = Faker::Lorem.sentence

      sub_section_payload_data = [
        {
          "title" => nil,
          "list" => [
            {
              "label" => label,
              "url" => url_with_querystring,
            },
          ],
        },
      ]

      output = described_class.call(sub_section_payload_data)
      lines = output[:content].split("\n")

      expect(lines.first).to eq "[#{label}](#{url})"
    end

    it "removes any priority-taxons query parameters from featured links" do
      url = "/#{File.join(Faker::Lorem.words)}"
      query_string = "?priority-taxon=774cee22-d896-44c1-a611-e3109cce8eae"
      url_with_querystring = "#{url}#{query_string}"

      sub_section_payload_data = [
        {
          "title" => nil,
          "list" => [
            {
              "label" => "Label",
              "url" => url_with_querystring,
              "featured_link" => true,
              "description" => "description",
            },
          ],
        },
      ]

      output = described_class.call(sub_section_payload_data)

      expect(output[:action_link_url]).to eq(url)
    end
  end
end
