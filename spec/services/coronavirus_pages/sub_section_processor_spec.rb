require "rails_helper"

RSpec.describe CoronavirusPages::SubSectionProcessor do
  let(:title) { Faker::Lorem.sentence }
  let(:label) { Faker::Lorem.sentence }
  let(:url) { "/#{File.join(Faker::Lorem.words)}" }
  let(:label_1) { Faker::Lorem.sentence }
  let(:url_1) { "/#{File.join(Faker::Lorem.words)}" }
  let(:data) do
    [
      {
        title: title,
        list: [
          {
            label: label,
            url: url,
          },
          {
            label: label_1,
            url: url_1,
          },
        ],
      },
    ]
  end

  describe ".call" do
    subject { described_class.call(data) }
    let(:lines) { subject.split("\n") }

    it "creates the correct number of lines" do
      # 3 = 1 title plus 2 links
      expect(lines.count).to eq 3
    end

    it "has title as the first line" do
      expect(lines.first).to eq "####{title}"
    end

    it "has the first link as the second line" do
      expect(lines.second).to eq "[#{label}](#{url})"
    end

    it "has the second link as the third line" do
      expect(lines.third).to eq "[#{label_1}](#{url_1})"
    end

    context "with blank title" do
      let(:title) { "" }

      it "has the first link as its first line" do
        expect(lines.first).to eq "[#{label}](#{url})"
      end
    end
  end
end
