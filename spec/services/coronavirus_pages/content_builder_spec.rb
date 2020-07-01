require "rails_helper"

RSpec.describe CoronavirusPages::ContentBuilder do
  let(:coronavirus_page) { create :coronavirus_page }
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:github_content) { YAML.safe_load(File.read(fixture_path)) }
  let(:sub_section_json) { SubSectionJsonPresenter.new(sub_section).output }
  let!(:live_stream) { create :live_stream, :without_validations }

  subject { described_class.new(coronavirus_page) }
  before do
    stub_request(:get, coronavirus_page.raw_content_url)
      .to_return(status: 200, body: github_content.to_json)
  end
  describe "#github_data" do
    it "returns github content" do
      expect(subject.github_data).to eq github_content["content"]
    end
  end

  describe "#data" do
    let(:sub_section) { create :sub_section }
    let(:coronavirus_page) { sub_section.coronavirus_page }
    let(:live_stream_data) do
      {
        "video_url" => live_stream.url,
        "date" => live_stream.formatted_stream_date,
      }
    end
    let(:data) do
      data = github_content["content"]
      data["content_sections"] = [sub_section_json]
      data["live_stream"] = live_stream_data
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
      let(:sub_section) { create :sub_section }
      let(:coronavirus_page) { sub_section.coronavirus_page }
      let(:sub_section_json) { SubSectionJsonPresenter.new(sub_section).output }
      it "returns the sub_section JSON" do
        expect(subject.sub_sections_data).to eq [sub_section_json]
      end
    end
  end

  describe "#success?" do
    it "is true if call successful" do
      expect(subject.success?).to be(true), subject.errors
    end

    context "on failure" do
      before do
        stub_request(:get, coronavirus_page.raw_content_url)
          .to_return(status: 400)
      end

      it "is false" do
        expect(subject.success?).to be(false)
      end
    end
  end
end
