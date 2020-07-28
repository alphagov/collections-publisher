require "rails_helper"

RSpec.describe CoronavirusPages::ModelBuilder do
  let(:slug) { "landing" }
  let(:model_builder) { CoronavirusPages::ModelBuilder.new(slug) }
  let(:page_config) { CoronavirusPages::Configuration.page(slug) }
  let(:raw_content_url) { page_config[:raw_content_url] }
  let(:raw_content_url_regex) { Regexp.new(raw_content_url) }
  let(:yaml_fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:source_yaml) { YAML.load_file(yaml_fixture_path) }
  let(:sections_title) { source_yaml.dig("content", "sections_heading") }
  let(:coronavirus_page_attributes) do
    page_config.merge(sections_title: sections_title, slug: slug)
  end

  before do
    stub_request(:get, raw_content_url_regex)
      .to_return(body: File.read(yaml_fixture_path))
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
    end

    context "a coronavirus page with matching slug is present in database" do
      let!(:coronavirus_page) { create :coronavirus_page, :landing }

      it "does not create a coronavirus page" do
        expect { model_builder.page }.not_to(change { CoronavirusPage.count })
      end

      it "returns the coronavirus page" do
        expect(model_builder.page).to eq(coronavirus_page)
      end
    end
  end

  describe "#discard_changes" do
    let(:content_fixture_path) { Rails.root.join("spec/fixtures/coronavirus_page_sections.json") }
    let(:live_content_item) { JSON.parse(File.read(content_fixture_path)) }
    let(:live_sections) { live_content_item.dig("details", "sections") }
    let(:live_title) { live_sections.first["title"] }
    let(:slug) { "landing" }
    let!(:coronavirus_page) do
      create :coronavirus_page,
             content_id: live_content_item["content_id"],
             base_path: live_content_item["base_path"],
             slug: slug
    end
    let!(:subsection) { create :sub_section, coronavirus_page_id: coronavirus_page.id, title: "foo" }
    let(:discard_changes) { CoronavirusPages::ModelBuilder.new(slug, :discard).discard_changes }
    before do
      stub_publishing_api_has_item(live_content_item)
    end

    it "replaces subsection attributes with those from the live content item" do
      expect(coronavirus_page.sub_sections.first.title).to eq "foo"
      discard_changes
      expect(coronavirus_page.sub_sections.first.title).to eq live_title
    end

    it "creates sub_sections with a position that reflects their order in the content item" do
      discard_changes
      input_order = live_sections.pluck("title").each_with_index.to_h.invert

      coronavirus_page.sub_sections.each do |sub_section|
        position = sub_section.position
        expect(input_order[position]).to eq(sub_section.title)
      end
    end
  end
end
