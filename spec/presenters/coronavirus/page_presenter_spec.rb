require "rails_helper"

RSpec.describe Coronavirus::PagePresenter do
  include CoronavirusFeatureSteps

  let(:page) { create :coronavirus_page }
  let(:base_path) { page.base_path }
  let(:data) { Coronavirus::Pages::ContentBuilder.new(page).data }
  let!(:title) { data["title"] }
  let(:details) { data.except("title") }

  let(:payload) do
    {
      "base_path" => base_path,
      "title" => title,
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
    stub_coronavirus_publishing_api
  end

  describe "#payload" do
    it "presents the payload correctly" do
      expect(subject.payload).to be_valid_against_publisher_schema("coronavirus_landing_page")
      expect(subject.payload).to eq payload
    end
  end
end
