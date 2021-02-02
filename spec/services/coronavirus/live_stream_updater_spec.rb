require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.describe Coronavirus::LiveStreamUpdater do
  include CoronavirusFeatureSteps
  include GdsApi::TestHelpers::PublishingApi

  before do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
    stub_live_coronavirus_content_request
    stub_yesterdays_youtube_link
    stub_todays_youtube_link
  end

  describe "#object" do
    it "creates live_stream object with data from the live content item" do
      updater = described_class.new
      expect(updater.object.url).to eq yesterdays_link
      expect(updater.object.formatted_stream_date).to eq yesterdays_date
    end

    it "returns live_stream object from the database if it exists" do
      create(:live_stream, url: todays_link, formatted_stream_date: todays_date)
      updater = described_class.new
      expect(updater.object.url).to eq todays_link
      expect(updater.object.formatted_stream_date).to eq todays_date
    end
  end

  context "Succesful interaction with publishing api" do
    it "#update and #publish" do
      create(:live_stream, url: todays_link, formatted_stream_date: todays_date)
      updater = described_class.new

      expect(updater.update).to be true
      expect(updater.publish).to be true

      expect(updater.object.url).to eql todays_link
      expect(updater.object.formatted_stream_date).to eql todays_date
    end
  end

  context "Unsuccesful interaction with publishing api" do
    it "#update" do
      create(:live_stream, url: todays_link, formatted_stream_date: todays_date)
      updater = described_class.new

      expect(updater.object.url).to eql todays_link
      expect(updater.object.formatted_stream_date).to eql todays_date

      stub_any_publishing_api_call_to_return_not_found
      expect(updater.update).to be false

      # rolls back the livestream database table to match the live content item
      expect(updater.object.url).to eql yesterdays_link
      expect(updater.object.formatted_stream_date).to eql yesterdays_date
    end

    it "#publish" do
      updater = described_class.new
      expect(updater.update).to be true
      stub_any_publishing_api_call_to_return_not_found
      expect(updater.publish).to be false
    end
  end
end
