require "rails_helper"

RSpec.describe CoronavirusPagePresenter do
  include CoronavirusFeatureSteps
  include GovukContentSchemaTestHelpers

  let(:coronavirus_page) { create :coronavirus_page, :landing }
  let(:base_path) { coronavirus_page.base_path }
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:github_content) { YAML.safe_load(File.read(fixture_path)) }
  let(:title) { github_content["content"]["title"] }
  let(:meta_description) { github_content["content"]["meta_description"] }
  let(:data) { CoronavirusPages::ContentBuilder.new(coronavirus_page).data }
  let(:details) { data.except(title, meta_description) }

  let(:payload) do
    {
      "base_path" => base_path,
      "title" => title,
      "description" => meta_description,
      "document_type" => "coronavirus_landing_page",
      "schema_name" => "coronavirus_landing_page",
      "details" => details,
      "links" => {},
      "locale" => "en",
      "rendering_app" => "collections",
      "publishing_app" => "collections-publisher",
      "routes" => [{ "path" => base_path, "type" => "exact" }],
      "update_type" => "minor",
    }
  end

  subject { described_class.new(data, base_path) }

  before do
    stub_request(:get, Regexp.new(coronavirus_page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)
    stub_coronavirus_publishing_api
  end

  describe "#payload" do
    it "presents the payload correctly" do
      expect(subject.payload).to be_valid_against_schema("coronavirus_landing_page")
      expect(subject.payload).to eq payload
    end

    it "includes announcements" do
      announcement = create(:announcement, coronavirus_page: coronavirus_page)
      expect(subject.payload["details"]["announcements"].count).to eq 1
      expect(subject.payload["details"]["announcements"].first).to eq({
        "href" => announcement.path,
        "text" => announcement.title,
        "published_text" => announcement.published_at.strftime("Published %-d %B %Y"),
      })
    end
  end
end
