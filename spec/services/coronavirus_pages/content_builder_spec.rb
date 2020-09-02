require "rails_helper"

RSpec.describe CoronavirusPages::ContentBuilder do
  let(:coronavirus_page) { create :coronavirus_page, :landing }
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:github_content) { YAML.safe_load(File.read(fixture_path)) }
  let(:sub_section_json) { SubSectionJsonPresenter.new(sub_section).output }
  let!(:live_stream) { create :live_stream, :without_validations }

  subject { described_class.new(coronavirus_page) }
  before do
    stub_request(:get, Regexp.new(coronavirus_page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)
  end
  describe "#github_data" do
    it "returns github content" do
      expect(subject.github_data).to eq github_content["content"]
    end
  end

  describe "#data" do
    let!(:sub_section) { create :sub_section, coronavirus_page_id: coronavirus_page.id }
    let(:github_livestream_data) { github_content.dig("content", "live_stream") }

    let(:live_stream_data) do
      github_livestream_data.merge(
        "video_url" => live_stream.url,
        "date" => live_stream.formatted_stream_date,
      )
    end

    let(:hidden_search_terms) do
      [
        sub_section_json[:title],
        sub_section_json[:sub_sections].first[:list].first[:label],
      ]
    end

    let(:data) do
      data = github_content["content"]
      data["sections"] = [sub_section_json]
      data["live_stream"] = live_stream_data
      data["hidden_search_terms"] = hidden_search_terms
      data
    end

    it "returns github and model data" do
      expect(subject.data).to eq data
    end
  end

  describe "#sub_sections_data" do
    it "returns the sub_sections" do
      expect(subject.sub_sections_data).to eq []
    end

    context "with subsections" do
      let!(:sub_section_0) { create :sub_section, position: 0, coronavirus_page: coronavirus_page }
      let!(:sub_section_1) { create :sub_section, position: 1, coronavirus_page: coronavirus_page }
      let(:sub_section_0_json) { SubSectionJsonPresenter.new(sub_section_0).output }
      let(:sub_section_1_json) { SubSectionJsonPresenter.new(sub_section_1).output }

      it "returns the sub_section JSON ordered by position" do
        expect(subject.sub_sections_data).to eq [sub_section_0_json, sub_section_1_json]
      end
    end
  end

  describe "#success?" do
    it "is true if call successful" do
      expect(subject.success?).to be(true), subject.errors
    end

    context "on failure" do
      before do
        stub_request(:get, Regexp.new(coronavirus_page.raw_content_url))
          .to_return(status: 400)
      end

      it "is false" do
        expect(subject.success?).to be(false)
      end
    end
  end
end
