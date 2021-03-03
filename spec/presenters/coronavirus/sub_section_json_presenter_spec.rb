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

    context "with unknown content" do
      let(:content) { [title_markup, link, "unknown"].join("\n") }

      it "raises an error" do
        expect { subject.output }.to raise_error(Coronavirus::SubSectionJsonPresenter::MarkdownInvalidError)
      end
    end

    context "with featured links" do
      it "looks up the description in Publishing API for a relative featured link" do
        sub_section.featured_link = path
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

      it "sets a nil description for an absolute featured link" do
        link = "https://example.com/path"
        sub_section.featured_link = link
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

  describe "#sub_section_hash_from_content_group" do
    let(:label) { Faker::Lorem.sentence }
    let(:path)  { "/#{File.join(Faker::Lorem.words)}" }
    let(:link) { "[#{label}](#{path})" }

    let(:group) { [link] }
    let(:sub_section_hash) { subject.sub_section_hash_from_content_group(group) }

    it "puts the link path and label into list" do
      expect(sub_section_hash[:list].first[:label]).to eq(label)
      expect(sub_section_hash[:list].first[:url]).to eq(path)
    end

    it "has a null title" do
      expect(sub_section_hash.keys).to include(:title)
      expect(sub_section_hash[:title]).to be_nil
    end

    context "with a title" do
      let(:title) { Faker::Lorem.sentence }
      let(:title_markup) { "## #{title}" }
      let(:group) { [title_markup, link] }

      it "puts the link path and label into list" do
        expect(sub_section_hash[:list].first[:label]).to eq(label)
        expect(sub_section_hash[:list].first[:url]).to eq(path)
      end

      it "has the title" do
        expect(sub_section_hash[:title]).to eq(title)
      end
    end

    context "with a spaceless title" do
      let(:title) { Faker::Lorem.sentence }
      let(:title_markup) { "###{title}" }
      let(:group) { [title_markup, link] }

      it "has the title" do
        expect(sub_section_hash[:title]).to eq(title)
      end
    end

    context "with a full url in link" do
      let(:url) { Faker::Internet.url }
      let(:link) { "[#{label}](#{url})" }

      it "puts the link path and label into list" do
        expect(sub_section_hash[:list].first[:label]).to eq(label)
        expect(sub_section_hash[:list].first[:url]).to eq(url)
      end
    end

    context "with a full secure url in link" do
      let(:url) { Faker::Internet.url }
      let(:link) { "[#{label}](#{url})" }

      it "puts the link path and label into list" do
        expect(sub_section_hash[:list].first[:label]).to eq(label)
        expect(sub_section_hash[:list].first[:url]).to eq(url)
      end
    end

    context "with spaces" do
      let(:link) { " [ #{label} ] ( #{path} ) " }

      it "puts the link path and label into list" do
        expect(sub_section_hash[:list].first[:label]).to eq(label)
        expect(sub_section_hash[:list].first[:url]).to eq(path)
      end
    end

    context "with two links" do
      let(:label_two) { Faker::Lorem.sentence }
      let(:path_two)  { "/#{File.join(Faker::Lorem.words)}" }
      let(:link_two) { "[#{label_two}](#{path_two})" }
      let(:group) { [link, link_two] }

      it "puts the link path and label into list" do
        expect(sub_section_hash[:list].first[:label]).to eq(label)
        expect(sub_section_hash[:list].first[:url]).to eq(path)
      end

      it "puts the second link path and label into list" do
        expect(sub_section_hash[:list].last[:label]).to eq(label_two)
        expect(sub_section_hash[:list].last[:url]).to eq(path_two)
      end
    end

    context "with unknown content" do
      let(:group) { %w[unknown] }

      it "adds an error" do
        expect { sub_section_hash }.to raise_error(Coronavirus::SubSectionJsonPresenter::MarkdownInvalidError)
      end
    end

    context "when link is to a subtopic path" do
      let(:business) { create :coronavirus_page, :business }
      let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
      let(:description) { "Find out about the government response to coronavirus (COVID-19) and what you need to do." }
      let(:path) { business.base_path }

      before do
        stub_request(:get, Regexp.new(business.raw_content_url))
          .to_return(body: File.read(fixture_path))
      end

      it "flags featured link" do
        expect(sub_section_hash[:list].first[:featured_link]).to eq(true)
      end

      it "includes description" do
        expect(sub_section_hash[:list].first[:description]).to eq(description)
      end
    end
  end

  describe "#content_groups" do
    it "contains the content in single inner array if no title in content" do
      expect(subject.content_groups).to eq([[content]])
    end

    context "with many links" do
      let(:content) { [link_one, link_two, link_three].join("\n") }

      it "returns them all in one inner array" do
        expect(subject.content_groups).to eq([[link_one, link_two, link_three]])
      end
    end

    context "with title then links" do
      let(:title) { random_title }
      let(:content) { [title, link_one, link_two].join("\n") }

      it "returns title and links in one inner array" do
        expect(subject.content_groups).to eq([[title, link_one, link_two]])
      end
    end

    context "with titles within links" do
      let(:title_one) { random_title }
      let(:title_two) { random_title }
      let(:content) { [link_one, title_one, link_two, title_two, link_three].join("\n") }

      it "returns the content in grouped arrays" do
        expect(subject.content_groups).to eq([[link_one], [title_one, link_two], [title_two, link_three]])
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
