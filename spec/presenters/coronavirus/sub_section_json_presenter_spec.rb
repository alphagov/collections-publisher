require "rails_helper"

RSpec.describe Coronavirus::SubSectionJsonPresenter do
  let(:link_one) { random_link_markdown }
  let(:link_two) { random_link_markdown }
  let(:link_three) { random_link_markdown }
  let(:content) { link_one }

  let(:sub_section) { build :coronavirus_sub_section, content: content }
  subject { described_class.new(sub_section) }

  describe "#title" do
    it "returns the sub section title" do
      expect(subject.title).to eq(sub_section.title)
    end
  end

  describe "#output" do
    let(:title) { Faker::Lorem.sentence }
    let(:title_markup) { "###{title}" }
    let(:label) { Faker::Lorem.sentence }
    let(:path)  { "/#{File.join(Faker::Lorem.words)}" }
    let(:link) { "[#{label}](#{path})" }
    let(:content) { [title_markup, link].join("\n") }

    let(:expected) do
      {
        title: subject.title,
        sub_sections: [
          {
            list: [
              {
                url: path,
                label: label,
              },
            ],
            title: title,
          },
        ],
      }
    end

    it "has expected content" do
      expect(subject.output).to eq(expected)
    end
  end

  describe "#build_link" do
    context "given a normal link" do
      it "builds a link hash for the publishing api" do
        expected_output = { label: "title", url: "/link" }
        expect(subject.build_link("title", "/link")).to eq(expected_output)
      end
    end

    context "when link is to a subtopic path" do
      let(:business) { create :coronavirus_page, :business }
      let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
      let(:subtopic_content_item_description) { "Find out about the government response to coronavirus (COVID-19) and what you need to do." }

      before do
        stub_request(:get, Regexp.new(business.raw_content_url))
          .to_return(body: File.read(fixture_path))
      end
      it "builds a link hash for the publishing api with a featured link" do
        expected_output = { label: "business", url: business.base_path, description: subtopic_content_item_description, featured_link: true }
        expect(subject.build_link("business", business.base_path)).to eq(expected_output)
      end
    end
  end

  describe "#sub_sections" do
    context "given multiple titles" do
      let(:content) { "#title \n [test](/coronavirus) \n #title2 \n [test2](/government)" }
      it "creates multiple groups" do
        expected_output =
          [
            {
              list: [{ label: "test", url: "/coronavirus" }],
              title: "title",
            },
            {
              list: [{ label: "test2", url: "/government" }],
              title: "title2",
            },
          ]
        expect(subject.sub_sections).to eq(expected_output)
      end
    end

    context "when the first group has no title" do
      let(:content) { "[test](/coronavirus) \n #title2 \n [test2](/government)" }
      it "groups the links as expected" do
        expected_output =
          [
            {
              list: [{ label: "test", url: "/coronavirus" }],
              title: nil,
            },
            {
              list: [{ label: "test2", url: "/government" }],
              title: "title2",
            },
          ]
        expect(subject.sub_sections).to eq(expected_output)
      end
    end

    context "when a sub-section contains an action link" do
      let(:title) { Faker::Lorem.sentence }
      let(:label) { Faker::Lorem.sentence }
      let(:path)  { "/#{File.join(Faker::Lorem.words)}" }
      let(:sub_section) do
        create :coronavirus_sub_section, content: "###{title}\n[#{label}](#{path})"
      end

      it "includes an action link with a description and featured set to true" do
        sub_section.action_link_url = "/bananas"
        sub_section.action_link_content = "Bananas"
        sub_section.action_link_summary = "Bananas"

        expected = [
          {
            list: [
              {
                url: "/bananas",
                label: "Bananas",
                description: "Bananas",
                featured_link: true,
              },
            ],
            title: nil,
          },
          {
            list: [
              {
                url: path,
                label: label,
              },
            ],
            title: title,
          },
        ]

        expect(subject.sub_sections).to eq(expected)
      end
    end

    context "when a priority taxon is provided" do
      it "appends the priority_taxon to the url if the link is relative" do
        link_url = "/hello-there"
        sub_section = build(:coronavirus_sub_section, content: "[General Kenobi](#{link_url})")
        priority_taxon = SecureRandom.uuid

        subject = described_class.new(sub_section, priority_taxon)
        sub_sections_list = subject.sub_sections.first[:list]

        expect(sub_sections_list).to include(
          hash_including(url: "#{link_url}?priority-taxon=#{priority_taxon}"),
        )
      end

      it "does not append a priority_taxon to the url if the link is external" do
        link_url = "http://www.hello-there.com"
        sub_section = build(:coronavirus_sub_section, content: "[General Kenobi](#{link_url})")

        subject = described_class.new(sub_section)
        sub_sections_list = subject.output[:sub_sections].first[:list]

        expect(sub_sections_list).to include(
          hash_including(url: link_url),
        )
      end
    end

    context "when a priority taxon is not provided" do
      it "does not append the priority-taxon to list urls" do
        sub_section = build(:coronavirus_sub_section, content: "[test](/coronavirus)")

        subject = described_class.new(sub_section)
        sub_sections_list = subject.sub_sections.first[:list]

        expect(sub_sections_list).to include(hash_including(url: "/coronavirus"))
      end
    end

    context "when a sub-section has an action link and a priority taxon is provided" do
      it "appends the priority_taxon to the action link url" do
        sub_section = build(:coronavirus_sub_section,
                            content: "#Title",
                            action_link_url: "/bananas",
                            action_link_content: Faker::Lorem.sentence,
                            action_link_summary: Faker::Lorem.sentence)

        priority_taxon = SecureRandom.uuid

        subject = described_class.new(sub_section, priority_taxon)
        sub_sections_list = subject.sub_sections.first[:list]

        expect(sub_sections_list).to include(
          hash_including(url: "/bananas?priority-taxon=#{priority_taxon}"),
        )
      end
    end
  end

  def random_link_markdown
    label = Faker::Lorem.sentence
    path = "/#{File.join(Faker::Lorem.words)}"
    "[#{label}](#{path})"
  end

  def random_title
    "### #{Faker::Lorem.sentence}"
  end
end
