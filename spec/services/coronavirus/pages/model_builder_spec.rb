require "rails_helper"

RSpec.describe Coronavirus::Pages::ModelBuilder do
  let(:slug) { "landing" }
  let(:model_builder) { Coronavirus::Pages::ModelBuilder.new(slug) }
  let(:page_config) { Coronavirus::Pages::Configuration.page }
  let(:raw_content_url) { page_config[:raw_content_url] }
  let(:raw_content_url_regex) { Regexp.new(raw_content_url) }
  let(:yaml_fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:source_yaml) { YAML.load_file(yaml_fixture_path) }
  let(:sections_title) { source_yaml.dig("content", "sections_heading") }
  let(:page_attributes) do
    page_config.merge(sections_title: sections_title, slug: slug)
  end

  before do
    stub_request(:get, raw_content_url_regex)
      .to_return(body: File.read(yaml_fixture_path))
  end

  describe ".call" do
    let(:page) { described_class.call(slug) }
    it "returns a page" do
      expect { page }.to change { Coronavirus::Page.count }.by(1)
      expect(page).to have_attributes(page_attributes)
    end
  end

  describe "#page" do
    context "coronavirus page with matching slug is absent from database" do
      it "creates a coronavirus page" do
        expect { model_builder.page }.to change { Coronavirus::Page.count }.by(1)
        expect(Coronavirus::Page.last).to have_attributes(page_attributes)
      end
    end

    context "a coronavirus page with matching slug is present in database" do
      let!(:page) { create :coronavirus_page }

      it "does not create a coronavirus page" do
        expect { model_builder.page }
          .not_to(change { Coronavirus::Page.count })
      end

      it "returns the coronavirus page" do
        expect(model_builder.page).to eq(page)
      end
    end
  end
end
