require "rails_helper"

RSpec.describe Coronavirus::Pages::DraftUpdater do
  include CoronavirusFeatureSteps

  let(:page) { create :coronavirus_page }
  let(:github_fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:github_content) { YAML.safe_load(File.read(github_fixture_path)) }

  before do
    stub_request(:get, Regexp.new(page.raw_content_url))
      .to_return(status: 200, body: github_content.to_json)
  end

  describe "#payload" do
    it "returns the payload for publishing-api" do
      stub_coronavirus_publishing_api
      content_builder = Coronavirus::Pages::ContentBuilder.new(page)
      expected_payload = Coronavirus::PagePresenter.new(content_builder.data, page.base_path).payload

      expect(described_class.new(page).payload).to eq expected_payload
    end

    it "catches InvalidContentError from ContentBuilder and adds a user friendly message" do
      allow(Coronavirus::Pages::ContentBuilder)
        .to receive(:new)
        .and_raise(Coronavirus::Pages::ContentBuilder::InvalidContentError)

      expect { described_class.new(page).payload }.to raise_error(
        Coronavirus::Pages::DraftUpdater::DraftUpdaterError,
        "Invalid content in one of the sub-sections",
      )
    end

    it "catches GitHubInvalidContentError from ContentBuilder and adds a user friendly message" do
      allow(Coronavirus::Pages::ContentBuilder)
        .to receive(:new)
        .and_raise(Coronavirus::Pages::ContentBuilder::GitHubInvalidContentError)

      expect { described_class.new(page).payload }.to raise_error(
        Coronavirus::Pages::DraftUpdater::DraftUpdaterError,
        "Invalid content in GitHub YAML",
      )
    end

    it "catches GitHubConnectionError from ContentBuilder and adds a user friendly message" do
      allow(Coronavirus::Pages::ContentBuilder)
        .to receive(:new)
        .and_raise(Coronavirus::Pages::ContentBuilder::GitHubConnectionError)

      expect { described_class.new(page).payload }.to raise_error(
        Coronavirus::Pages::DraftUpdater::DraftUpdaterError,
        "Unable to load content from GitHub",
      )
    end
  end

  describe "#discard" do
    it "raises an error if there isn't a draft to discard" do
      stub_any_publishing_api_discard_draft.to_return(status: 422)

      expect { described_class.new(page).discard }.to raise_error(
        Coronavirus::Pages::DraftUpdater::DraftUpdaterError,
        "You do not have a draft to discard",
      )
    end

    it "raises an error if publishing-api is not available" do
      stub_publishing_api_isnt_available

      expect { described_class.new(page).discard }.to raise_error(
        Coronavirus::Pages::DraftUpdater::DraftUpdaterError,
        "There has been an error discarding your changes. Try again.",
      )
    end
  end
end
