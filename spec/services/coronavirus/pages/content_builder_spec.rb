require "rails_helper"

RSpec.describe Coronavirus::Pages::ContentBuilder do
  let(:page) { create :coronavirus_page }
  let(:sub_section_json) { Coronavirus::SubSectionJsonPresenter.new(sub_section, page.content_id).output }

  subject { described_class.new(page) }

  describe "#data" do
    let!(:sub_section) { create :coronavirus_sub_section, page: page }
    let(:hidden_search_terms) do
      [
        sub_section_json[:title],
        sub_section_json[:sub_sections].first[:list].first[:label],
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

    it "returns model data" do
      data = {}
      data["title"] = "Coronavirus (COVID-19): guidance and support"
      data["header_section"] = header_json
      data["sections"] = [sub_section_json]
      data["hidden_search_terms"] = hidden_search_terms

      expect(subject.data).to eq data
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
end
