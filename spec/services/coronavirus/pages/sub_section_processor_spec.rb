require "rails_helper"

RSpec.describe Coronavirus::Pages::SubSectionProcessor do
  let(:title) { Faker::Lorem.sentence }
  let(:label) { Faker::Lorem.sentence }
  let(:description) { Faker::Lorem.sentence }
  let(:url) { "/#{File.join(Faker::Lorem.words)}" }
  let(:label_1) { Faker::Lorem.sentence }
  let(:url_1) { "/#{File.join(Faker::Lorem.words)}?priority-taxon=774cee22-d896-44c1-a611-e3109cce8eae" }
  let(:data) do
    [
      {
        "title" => title,
        "list" => [
          {
            "label" => label,
            "url" => url,
            "featured_link" => true,
            "description" => description,
          },
          {
            "label" => label_1,
            "url" => url_1,
          },
        ],
      },
    ]
  end

  describe ".call" do
    subject { described_class.call(data) }
    let(:lines) { subject[:content].split("\n") }

    it "creates the correct number of lines" do
      # 2 = 1 title plus 1 link - feature_link's aren't created
      expect(lines.count).to eq(2)
    end

    it "has title as the first line" do
      expect(lines.first).to eq "####{title}"
    end

    it "stores the url, label and description in the appropriate action_link fields" do
      expect(subject).to match hash_including(
        action_link_url: url,
        action_link_content: label,
        action_link_summary: description,
      )
    end

    it "removes any priority-taxons query parameters from any non-featured links" do
      expect(lines.second).to eq "[#{label_1}](#{url_1.gsub('?priority-taxon=774cee22-d896-44c1-a611-e3109cce8eae', '')})"
    end

    context "with blank title" do
      let(:data) do
        {
          "title" => nil,
          "list" => [
            {
              "label" => label,
              "url" => url,
            },
          ],
        }
      end

      it "has the first link as its first line" do
        expect(lines.first).to eq "[#{label}](#{url})"
      end
    end
  end
end
