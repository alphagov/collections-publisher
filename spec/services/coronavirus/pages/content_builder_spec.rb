require "rails_helper"

RSpec.describe Coronavirus::Pages::ContentBuilder do
  let(:page) { create :coronavirus_page }
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:github_content) { YAML.safe_load(File.read(fixture_path)) }
  let(:sub_section_json) { Coronavirus::SubSectionJsonPresenter.new(sub_section, page.content_id).output }
  let(:timeline_json) do
    {
      "heading" => timeline_entry["heading"],
      "paragraph" => timeline_entry["content"],
      "national_applicability" => timeline_entry["national_applicability"],
    }
  end

  subject { described_class.new(page) }
  before do
    stub_request(:get, Regexp.new(page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)
  end

  describe "#github_raw_data" do
    it "returns an error if GitHub is unavailable" do
      stub_request(:get, Regexp.new(page.raw_content_url))
        .to_return(status: 500)

      expect { subject.github_raw_data }.to raise_error(Coronavirus::Pages::ContentBuilder::GitHubConnectionError)
    end
  end

  describe "#validate_content" do
    it "returns an error if GitHub is missing required keys" do
      allow(subject)
        .to receive(:github_data)
        .and_return(github_content["content"].except("title"))

      expect { subject.validate_content }.to raise_error(Coronavirus::Pages::ContentBuilder::GitHubInvalidContentError)
    end
  end

  describe "#github_data" do
    it "returns github content" do
      expect(subject.github_data).to eq github_content["content"]
    end
  end

  describe "#data" do
    let!(:sub_section) { create :coronavirus_sub_section, page: page }
    let!(:timeline_entry) { create :coronavirus_timeline_entry, page: page }
    let(:data) { github_content["content"].deep_dup }

    let(:hidden_search_terms) do
      [
        sub_section_json[:title],
        sub_section_json[:sub_sections].first[:list].first[:label],
        data["timeline"]["list"].first["heading"],
        MarkdownService.new.strip_markdown(data["timeline"]["list"].first["paragraph"]),
      ]
    end

    let(:header_json) do
      {
        "title" => page.header_title,
        "intro" => page.header_body,
        "link" => {
          "href" => page.header_link_url,
          "link_text" => page.header_link_pre_wrap_text,
          "link_nowrap_text" => page.header_link_post_wrap_text,
        },
      }
    end

    before do
      data["header_section"] = header_json
      data["sections"] = [sub_section_json]
      data["timeline"]["list"] = [timeline_json]
      data["hidden_search_terms"] = hidden_search_terms
    end

    it "returns github and model data" do
      expect(subject.data).to eq data
    end

    it "includes the timeline data from github" do
      expect(subject.data["timeline"]["list"])
        .to eq([timeline_json])
    end
  end

  describe "#sub_sections_data" do
    it "returns the sub_sections" do
      expect(subject.sub_sections_data).to eq []
    end

    context "with subsections" do
      let!(:sub_section_0) { create :coronavirus_sub_section, position: 0, page: page }
      let!(:sub_section_1) { create :coronavirus_sub_section, position: 1, page: page }
      let(:sub_section_0_json) { Coronavirus::SubSectionJsonPresenter.new(sub_section_0).output }
      let(:sub_section_1_json) { Coronavirus::SubSectionJsonPresenter.new(sub_section_1).output }

      it "returns the sub_section JSON ordered by position" do
        expect(subject.sub_sections_data).to eq [sub_section_0_json, sub_section_1_json]
      end
    end
  end

  describe "#timeline_data" do
    let!(:timeline_entry_0) { create :coronavirus_timeline_entry, position: 2, page: page  }
    let!(:timeline_entry_1) { create :coronavirus_timeline_entry, position: 1, page: page  }

    it "returns the timeline JSON ordered by position" do
      expect(subject.timeline_data).to eq [
        {
          "heading" => timeline_entry_1.heading,
          "paragraph" => timeline_entry_1.content,
          "national_applicability" => timeline_entry_1.national_applicability,
        },
        {
          "heading" => timeline_entry_0.heading,
          "paragraph" => timeline_entry_0.content,
          "national_applicability" => timeline_entry_0.national_applicability,
        },
      ]
    end

    describe "#header_data" do
      it "returns the header section JSON" do
        page = create(
          :coronavirus_page,
          header_title: "Header section title",
          header_body: "Header section body",
          header_link_url: "/foo-bar",
          header_link_pre_wrap_text: "Text before the wrap",
          header_link_post_wrap_text: "and text after",
        )

        expected_header_section = {
          "title" => page.header_title,
          "intro" => page.header_body,
          "link" => {
            "href" => page.header_link_url,
            "link_text" => page.header_link_pre_wrap_text,
            "link_nowrap_text" => page.header_link_post_wrap_text,
          },
        }

        expect(described_class.new(page).header_data).to eq(expected_header_section)
      end
    end
  end
end
