require "rails_helper"

RSpec.describe SubSectionJsonPresenter do
  let(:link_one) { random_link_markdown }
  let(:link_two) { random_link_markdown }
  let(:link_three) { random_link_markdown }
  let(:content) { link_one }

  let(:sub_section) { build :sub_section, content: content }
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
    let(:link) { "(#{label})[#{path}]" }
    let(:content) { [title_markup, link].join("\n") }

    let(:expected) do
      {
        details: {
          sections: [
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
            },
          ],
        },
      }
    end

    it "has expected content" do
      expect(subject.output).to eq(expected)
    end
  end

  describe "#sub_section_hash_from_content_group" do
    let(:label) { Faker::Lorem.sentence }
    let(:path)  { "/#{File.join(Faker::Lorem.words)}" }
    let(:link) { "(#{label})[#{path}]" }

    let(:group) { [link] }
    let(:hash) { subject.sub_section_hash_from_content_group(group) }

    it "puts the link path and label into list" do
      expect(hash[:list].first[:label]).to eq(label)
      expect(hash[:list].first[:url]).to eq(path)
    end

    it "has a null title" do
      expect(hash.keys).to include(:title)
      expect(hash[:title]).to be_nil
    end

    context "with a title" do
      let(:title) { Faker::Lorem.sentence }
      let(:title_markup) { "## #{title}" }
      let(:group) { [title_markup, link] }

      it "puts the link path and label into list" do
        expect(hash[:list].first[:label]).to eq(label)
        expect(hash[:list].first[:url]).to eq(path)
      end

      it "has the title" do
        expect(hash[:title]).to eq(title)
      end
    end

    context "with a spaceless title" do
      let(:title) { Faker::Lorem.sentence }
      let(:title_markup) { "###{title}" }
      let(:group) { [title_markup, link] }

      it "has the title" do
        expect(hash[:title]).to eq(title)
      end
    end

    context "with two links" do
      let(:label_two) { Faker::Lorem.sentence }
      let(:path_two)  { "/#{File.join(Faker::Lorem.words)}" }
      let(:link_two) { "(#{label_two})[#{path_two}]" }
      let(:group) { [link, link_two] }

      it "puts the link path and label into list" do
        expect(hash[:list].first[:label]).to eq(label)
        expect(hash[:list].first[:url]).to eq(path)
      end

      it "puts the second link path and label into list" do
        expect(hash[:list].last[:label]).to eq(label_two)
        expect(hash[:list].last[:url]).to eq(path_two)
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
    "(#{label})[#{path}]"
  end

  def random_title
    "### #{Faker::Lorem.sentence}"
  end
end
