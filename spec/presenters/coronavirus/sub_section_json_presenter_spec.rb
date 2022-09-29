require "rails_helper"

RSpec.describe Coronavirus::SubSectionJsonPresenter do
  describe "#output" do
    let(:sub_section) { build :coronavirus_sub_section }

    it "has expected content" do
      title = Faker::Lorem.sentence
      label = Faker::Lorem.sentence
      url = "/#{File.join(Faker::Lorem.words)}"
      sub_section.content = "###{title} \n [#{label}](#{url})"

      expected_output = {
        title: sub_section.title,
        sub_heading: sub_section.sub_heading,
        sub_sections: [
          {
            list: [
              {
                url:,
                label:,
              },
            ],
            title:,
          },
        ],
      }

      presenter = described_class.new(sub_section)
      expect(presenter.output).to eq(expected_output)
    end

    context "given multiple titles" do
      it "creates multiple groups" do
        sub_section.content = "#title \n [test](/coronavirus) \n #title2 \n [test2](/government)"

        expected_output = {
          title: sub_section.title,
          sub_heading: sub_section.sub_heading,
          sub_sections: [
            {
              list: [
                {
                  label: "test",
                  url: "/coronavirus",
                },
              ],
              title: "title",
            },
            {
              list: [
                {
                  label: "test2",
                  url: "/government",
                },
              ],
              title: "title2",
            },
          ],
        }

        presenter = described_class.new(sub_section)
        expect(presenter.output).to eq(expected_output)
      end
    end

    context "when the first group has no title" do
      it "groups the links as expected" do
        sub_section.content = "[test](/coronavirus) \n #title2 \n [test2](/government)"

        expected_output = {
          title: sub_section.title,
          sub_heading: sub_section.sub_heading,
          sub_sections: [
            {
              list: [
                {
                  label: "test",
                  url: "/coronavirus",
                },
              ],
              title: nil,
            },
            {
              list: [
                {
                  label: "test2",
                  url: "/government",
                },
              ],
              title: "title2",
            },
          ],
        }

        presenter = described_class.new(sub_section)
        expect(presenter.output).to eq(expected_output)
      end
    end

    context "when a sub-section contains an action link" do
      it "includes an action link with a description and featured set to true" do
        title = Faker::Lorem.sentence
        label = Faker::Lorem.sentence
        url = "/#{File.join(Faker::Lorem.words)}"
        sub_section.content = "###{title}\n[#{label}](#{url})"

        sub_section.action_link_url = "/bananas"
        sub_section.action_link_content = "Bananas"
        sub_section.action_link_summary = "Bananas"

        expected_output = {
          title: sub_section.title,
          sub_heading: sub_section.sub_heading,
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
                  url:,
                  label:,
                },
              ],
              title:,
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
        sub_section.content = "[General Kenobi](#{link_url})"
        priority_taxon = SecureRandom.uuid

        presenter = described_class.new(sub_section, priority_taxon)
        sub_sections_list = presenter.output[:sub_sections].first[:list]

        expect(sub_sections_list).to include(
          hash_including(url: "#{link_url}?priority-taxon=#{priority_taxon}"),
        )
      end

      it "does not append a priority_taxon to the url if the link is external" do
        link_url = "http://www.hello-there.com"
        sub_section.content = "[General Kenobi](#{link_url})"

        presenter = described_class.new(sub_section)
        sub_sections_list = presenter.output[:sub_sections].first[:list]

        expect(sub_sections_list).to include(
          hash_including(url: link_url),
        )
      end

      it "appends the priority_taxon to action link urls" do
        link_url = "/bananas"
        sub_section.action_link_url = link_url
        priority_taxon = SecureRandom.uuid

        presenter = described_class.new(sub_section, priority_taxon)
        sub_sections_list = presenter.output[:sub_sections].first[:list]

        expect(sub_sections_list).to include(
          hash_including(url: "#{link_url}?priority-taxon=#{priority_taxon}"),
        )
      end
    end
  end
end
