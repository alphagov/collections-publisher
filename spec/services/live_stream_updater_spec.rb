require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.describe LiveStreamUpdater do
  include GdsApi::TestHelpers::PublishingApi

  before do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
  end

  describe "#initialize" do
    it "finds or creates a livestream object" do
      stub_live_content_request
      stub_youtube_link

      live_stream = LiveStreamUpdater.new.object
      expect(live_stream.url).to eq live_url
    end
  end

  context "Succesful interaction with publishing api" do
    it "#update and #publish?" do
      stub_live_content_request
      stub_youtube_link

      updater = LiveStreamUpdater.new
      expect(updater.update?).to be true
      expect(updater.publish?).to be true
    end
  end

  context "Unsuccesful interaction with publishing api" do
    it "#update?" do
      stub_live_content_request
      stub_youtube_link

      updater = LiveStreamUpdater.new
      stub_any_publishing_api_call_to_return_not_found
      expect(updater.update?).to be false
    end

    it "#publish? " do
      stub_live_content_request
      stub_youtube_link

      updater = LiveStreamUpdater.new
      expect(updater.update?).to be true
      stub_any_publishing_api_call_to_return_not_found
      expect(updater.publish?).to be false
    end
  end

  def live_content_item
    File.read(Rails.root.join + "spec/fixtures/coronavirus_content_item.json")
  end

  def live_url
    h = JSON.parse(live_content_item)
    h["details"]["live_stream"]["video_url"]
  end

  def stub_live_content_request
    stub_publishing_api_has_item(JSON.parse(live_content_item))
  end

  def stub_youtube_link
    stub_request(:get, live_url)
  end
end
