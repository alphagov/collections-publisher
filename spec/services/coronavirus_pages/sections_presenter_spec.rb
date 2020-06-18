require "rails_helper"

RSpec.describe CoronavirusPages::SectionsPresenter do
  let(:title) { Faker::Lorem.sentence }
  let(:data) do
    [
      {
        title: title,
        sub_sections: [
          {
            title: "title",
            list: [
              {
                label: "Stay at home if you think you have coronavirus (self-isolating)",
                url: " /government/publications/covid-19-stay-at-home-guidance",
              },
              {
                label: "Stay alert and safe: social distancing guidance for everyone",
                url: "/government/publications/staying-alert-and-safe-social-distancing",
              },
            ],
          },
        ],
      },
    ]
  end

  describe "#output" do
    subject { described_class.new(data).output }

    it "produces an array of hashes" do
      expect(subject).to be_an(Array)
      expect(subject.first).to be_a(Hash)
      expect(subject.first.keys).to contain_exactly(:title, :content)
    end

    it "parses the title" do
      expect(subject.first[:title]).to eq title
    end

    it "parses the content" do
      expect(subject.first[:content]).to be_a(String)
      expect(subject.first[:content].lines.count).to eq 3
    end
  end
end
