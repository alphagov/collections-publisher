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
      expect { page }.to change { Coronavirus::CoronavirusPage.count }.by(1)
      expect(page).to have_attributes(coronavirus_page_attributes)
    end
  end

  describe "#page" do
    context "coronavirus page with matching slug is absent from database" do
      it "creates a coronavirus page" do
        expect { model_builder.page }.to change { Coronavirus::CoronavirusPage.count }.by(1)
        expect(Coronavirus::CoronavirusPage.last)
          .to have_attributes(coronavirus_page_attributes)
      end
    end

    context "a coronavirus page with matching slug is present in database" do
      let!(:coronavirus_page) { create :coronavirus_page, :landing }

      it "does not create a coronavirus page" do
        expect { model_builder.page }
          .not_to(change { Coronavirus::CoronavirusPage.count })
      end

      it "returns the coronavirus page" do
        expect(model_builder.page).to eq(coronavirus_page)
      end
    end
  end
end
