require "rails_helper"

RSpec.describe Coronavirus::SubSectionJsonPresenter do
  describe "#output" do
    let(:title) { Faker::Lorem.sentence }
    let(:title_markup) { "###{title}" }
    let(:label) { Faker::Lorem.sentence }
    let(:path)  { "/#{File.join(Faker::Lorem.words)}" }
    let(:link) { "[#{label}](#{path})" }
    let(:content) { [title_markup, link].join("\n") }
    let(:sub_section) { build :coronavirus_sub_section, content: content }

    it "has expected content" do
      expected_output = {
        title: sub_section.title,
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

      presenter = described_class.new(sub_section)
      expect(presenter.output).to eq(expected_output)
    end
  end

  context "given multiple titles" do
    let(:content) { "#title \n [test](/coronavirus) \n #title2 \n [test2](/government)" }
    let(:sub_section) { build :coronavirus_sub_section, content: content }

    it "creates multiple groups" do
      expected_output = {
        title: sub_section.title,
        sub_sections: [
          {
            list: [{ label: "test", url: "/coronavirus" }],
            title: "title",
          },
          {
            list: [{ label: "test2", url: "/government" }],
            title: "title2",
          },
        ],
      }

      presenter = described_class.new(sub_section)
      expect(presenter.output).to eq(expected_output)
    end
  end

  context "when the first group has no title" do
    let(:content) { "[test](/coronavirus) \n #title2 \n [test2](/government)" }
    let(:sub_section) { build :coronavirus_sub_section, content: content }

    it "groups the links as expected" do
      expected_output = {
        title: sub_section.title,
        sub_sections: [
          {
            list: [{ label: "test", url: "/coronavirus" }],
            title: nil,
          },
          {
            list: [{ label: "test2", url: "/government" }],
            title: "title2",
          },
        ],
      }

      presenter = described_class.new(sub_section)
      expect(presenter.output).to eq(expected_output)
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

      expected_output = {
        title: sub_section.title,
        sub_sections: [
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
        ],
      }

      presenter = described_class.new(sub_section)
      expect(presenter.output).to eq(expected_output)
    end
  end

  context "when a priority taxon is provided" do
    it "appends the priority_taxon to the url if the link is relative" do
      link_url = "/hello-there"
      sub_section = build(:coronavirus_sub_section, content: "[General Kenobi](#{link_url})")
      priority_taxon = SecureRandom.uuid

      presenter = described_class.new(sub_section, priority_taxon)
      sub_sections_list = presenter.output[:sub_sections].first[:list]

      expect(sub_sections_list).to include(
        hash_including(url: "#{link_url}?priority-taxon=#{priority_taxon}"),
      )
    end

    it "does not append a priority_taxon to the url if the link is external" do
      link_url = "http://www.hello-there.com"
      sub_section = build(:coronavirus_sub_section, content: "[General Kenobi](#{link_url})")

      presenter = described_class.new(sub_section)
      sub_sections_list = presenter.output[:sub_sections].first[:list]

      expect(sub_sections_list).to include(
        hash_including(url: link_url),
      )
    end
  end

  context "when a priority taxon is not provided" do
    it "does not append the priority-taxon to list urls" do
      sub_section = build(:coronavirus_sub_section, content: "[test](/coronavirus)")

      presenter = described_class.new(sub_section)
      sub_sections_list = presenter.output[:sub_sections].first[:list]

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

      presenter = described_class.new(sub_section, priority_taxon)
      sub_sections_list = presenter.output[:sub_sections].first[:list]

      expect(sub_sections_list).to include(
        hash_including(url: "/bananas?priority-taxon=#{priority_taxon}"),
      )
    end
  end
end
