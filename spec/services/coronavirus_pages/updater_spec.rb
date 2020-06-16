require "rails_helper"

RSpec.describe CoronavirusPages::Updater do
  let(:slug) { "landing" }
  let(:updater) { CoronavirusPages::Updater.new(slug) }
  let(:raw_content_url) { CoronavirusPages::Configuration.page(slug)[:raw_content_url] }
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:source_yaml) { YAML.load_file(fixture_path) }
  let(:source_sections) { source_yaml.dig("content", "sections") }

  before do
    stub_request(:get, raw_content_url)
      .to_return(body: File.read(fixture_path))
  end

  describe "#page" do
    context "coronavirus page with matching slug is absent from database" do
      it "creates a coronavirus page" do
        expect { updater.page }.to change { CoronavirusPage.count }.by(1)
      end

      it "creates associated sub_sections" do
        expect { updater.page }.to(change { SubSection.count }.by(source_sections.count))
      end
    end

    context "for a known section" do
      let(:section) { source_sections.sample }
      let(:sub_section) { SubSection.find_by(title: section["title"]) }

      it "creates sub_sections with the given attributes" do
        updater.page
        expect(sub_section.content).to include(section["sub_sections"].first["list"].first["label"])
      end
    end

    context "a coronavirus page with matching slug is present in database" do
      let!(:coronavirus_page) { create :coronavirus_page, :landing }

      it "does not create a coronavirus page" do
        expect { updater.page }.not_to(change { CoronavirusPage.count })
      end

      it "returns the coronavirus page" do
        expect(updater.page).to eq(coronavirus_page)
      end

      it "does not create sub_sections" do
        expect { updater.page }.not_to(change { SubSection.count })
      end
    end
  end
end
