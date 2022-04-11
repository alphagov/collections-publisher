require "rails_helper"

RSpec.describe Coronavirus::Pages::DraftUpdater do
  include CoronavirusFeatureSteps

  let(:page) { create :coronavirus_page }

  describe "#payload" do
    it "returns the payload for publishing-api" do
      stub_coronavirus_publishing_api
      content_builder = Coronavirus::Pages::ContentBuilder.new(page)
      expected_payload = Coronavirus::PagePresenter.new(content_builder.data, page.base_path).payload

      expect(described_class.new(page).payload).to eq expected_payload
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

  describe "#send" do
    it "raises an error if publishing-api is not available" do
      stub_publishing_api_isnt_available

      expect { described_class.new(page).send }.to raise_error(
        Coronavirus::Pages::DraftUpdater::DraftUpdaterError,
        "Failed to update the draft content item. Try saving again.",
      )
    end
  end
end
