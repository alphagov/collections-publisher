require "rails_helper"

RSpec.describe CoronavirusPages::ModelBuilder do
  let(:slug) { "landing" }
  let(:model_builder) { CoronavirusPages::ModelBuilder.new(slug) }
  let(:page_config) { CoronavirusPages::Configuration.page(slug) }
  let(:raw_content_url) { page_config[:raw_content_url] }
  let(:raw_content_url_regex) { Regexp.new(raw_content_url) }
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:source_yaml) { YAML.load_file(fixture_path) }
  let(:source_sections) { source_yaml.dig("content", "sections") }
  let(:sections_title) { source_yaml.dig("content", "sections_heading") }
  let(:coronavirus_page_attributes) do
    page_config.merge(sections_title: sections_title, slug: slug)
  end

  before do
    stub_request(:get, raw_content_url_regex)
      .to_return(body: File.read(fixture_path))
  end

  describe ".call" do
    let(:page) { described_class.call(slug) }
    it "returns a page" do
      expect { page }.to change { CoronavirusPage.count }.by(1)
      expect(page).to have_attributes(coronavirus_page_attributes)
    end
  end

  describe "#page" do
    context "coronavirus page with matching slug is absent from database" do
      it "creates a coronavirus page" do
        expect { model_builder.page }.to change { CoronavirusPage.count }.by(1)
        expect(CoronavirusPage.last).to have_attributes(coronavirus_page_attributes)
      end

      it "creates associated sub_sections" do
        expect { model_builder.page }.to(change { SubSection.count }.by(source_sections.count))
      end
    end

    context "for a known section" do
      let(:section) { source_sections.sample }
      let(:sub_section) { SubSection.find_by(title: section["title"]) }

      it "creates sub_sections with the given attributes" do
        model_builder.page
        expect(sub_section.content).to include(section["sub_sections"].first["list"].first["label"])
      end

      it "creates sub_sections with a position that reflects their order in the content item" do
        input_order =
          source_sections.pluck("title").each_with_index.to_h.invert

        # {0=>"How to protect yourself and others",
        #  1=>"Employment and financial support",
        #  2=>"School closures, education, and childcare",
        #  3=>"Businesses and other organisations",
        #  4=>"Healthcare workers and carers",
        #  5=>"Travel",
        #  6=>"How coronavirus is affecting public services",
        #  7=>"How you can help",
        #  8=>"Coronavirus (COVID-19) cases in the UK"}

        model_builder.page.sub_sections.each do |sub_section|
          i = sub_section.position
          expect(input_order[i]).to eq(sub_section.title)
        end
      end
    end

    context "a coronavirus page with matching slug is present in database" do
      let!(:coronavirus_page) { create :coronavirus_page, :landing }

      it "does not create a coronavirus page" do
        expect { model_builder.page }.not_to(change { CoronavirusPage.count })
      end

      it "returns the coronavirus page" do
        expect(model_builder.page).to eq(coronavirus_page)
      end

      it "does not create sub_sections" do
        expect { model_builder.page }.not_to(change { SubSection.count })
      end
    end
  end
end
