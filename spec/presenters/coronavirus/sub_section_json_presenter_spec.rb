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

    context "with action link" do
      it "looks up the description in Publishing API for a relative action link" do
        sub_section.action_link_url = path
        description = Faker::Lorem.sentence

        content_id = SecureRandom.uuid
        stub_publishing_api_has_item(
          base_path: path,
          content_id: content_id,
          description: description,
        )
        stub_publishing_api_has_lookups(path.to_s => content_id)

        sub_sections_list = subject.output[:sub_sections].first[:list]

        expect(sub_sections_list).to include(
          hash_including(
            url: path,
            featured_link: true,
            description: description,
          ),
        )
      end

      it "sets a nil description for an absolute action link" do
        link = "https://example.com/path"
        sub_section.action_link_url = link
        sub_section.content = "[text](#{link})"

        sub_sections_list = subject.output[:sub_sections].first[:list]

        expect(sub_sections_list).to include(
          hash_including(
            url: link,
            featured_link: true,
            description: nil,
          ),
        )
      end
    end
  end

  describe "#build_link" do
    context "given a normal link" do
      it "builds a link hash for the publishing api" do
        expected_output = { label: "title", url: "/link" }
        expect(subject.build_link("title", "/link")).to eq(expected_output)
      end
    end

    context "given a action link" do
      it "builds a link hash for the publishing api with a featured link" do
        allow(subject).to receive(:description_for_featured_link).and_return("description")

        sub_section.action_link_url = "/link"
        expected_output = { label: "title", url: "/link", description: "description", featured_link: true }
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
