require "rails_helper"

RSpec.describe CoronavirusPagePresenter do
  include GovukContentSchemaTestHelpers

  let(:content) {
    {
      "title" => "coronavirus",
      "meta_description" => "details about the coronavirus response",
      "sections" => "some sections",
    }
  }

  let(:landing_page_path) { "/coronavirus" }
  let(:payload) {
    {
      "base_path" => landing_page_path,
      "title" => "coronavirus",
      "description" => "details about the coronavirus response",
      "document_type" => "coronavirus_landing_page",
      "schema_name" => "coronavirus_landing_page",
      "details" => {},
      "links" => {},
      "locale" => "en",
      "rendering_app" => "collections",
      "publishing_app" => "collections-publisher",
      "routes" => [
        { "path" => landing_page_path, "type" => "exact" },
      ],
      "update_type" => "minor",
    }
  }

  let(:new_url) { "https://www.youtube.com/123" }
  let(:new_date) { "2 April 2020" }

  subject { described_class.new(content, landing_page_path) }

  before do
    stub_request(:get, video_url_from_content_item)
    stub_request(:get, new_url)
    stub_publishing_api_has_item(JSON.parse(live_content_item))
  end

  describe "#payload" do
    # this situation will only arise the first time the application is deployed,
    # and if a content change is published before a livestream is created.
    context "when no livestream objects exist in the database" do
      it "presents the payload correctly" do
        presented = subject.payload
        details = {
          "details" => {
            "sections" => "some sections",
            "live_stream" => {
              "video_url" => video_url_from_content_item,
              "date" => date_from_content_item,
            },
          },
        }
        expect(presented).to be_valid_against_schema("coronavirus_landing_page")
        expect(presented).to eq payload.merge(details)
      end
    end

    context "when a livestream object exists in the database" do
      it "presents the payload correctly" do
        LiveStream.create(url: new_url, formatted_stream_date: new_date)
        presented = subject.payload
        details = {
          "details" => {
            "sections" => "some sections",
            "live_stream" => {
              "video_url" => new_url,
              "date" => new_date,
            },
          },
        }
        expect(presented).to be_valid_against_schema("coronavirus_landing_page")
        expect(presented).to eq payload.merge(details)
      end
    end
  end

  def live_content_item
    File.read(Rails.root.join + "spec/fixtures/coronavirus_content_item.json")
  end

  def video_url_from_content_item
    h = JSON.parse(live_content_item)
    h["details"]["live_stream"]["video_url"]
  end

  def date_from_content_item
    h = JSON.parse(live_content_item)
    h["details"]["live_stream"]["date"]
  end
end
