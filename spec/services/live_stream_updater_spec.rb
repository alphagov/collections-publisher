require "rails_helper"
require "gds_api/test_helpers/publishing_api"

RSpec.describe LiveStreamUpdater do
  include GdsApi::TestHelpers::PublishingApi

  before do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_publish
  end

  context "Succesful interaction with publishing api" do
    it "turns live stream on" do
      stub_live_content_request
      live_stream = LiveStream.create
      expect(live_stream.state).to be false

      updater = LiveStreamUpdater.new(live_stream, true)

      expect(updater.updated?).to be true
      expect(updater.published?).to be true
      expect(live_stream.state).to be true
      payload = updater.send(:live_stream_payload)
      assert_publishing_api_put_content(landing_page_id, payload)
    end

    it "turns live stream off" do
      stub_live_content_request
      live_stream = LiveStream.create.toggle(:state)
      expect(live_stream.state).to be true

      updater = LiveStreamUpdater.new(live_stream, false)
      payload = updater.send(:live_stream_payload)

      expect(updater.updated?).to be true
      expect(updater.published?).to be true
      expect(live_stream.state).to be false
      assert_publishing_api_put_content(landing_page_id, payload)
    end
  end

  context "Unsuccesful interaction with publishing api" do
    it "handles failure to update" do
      stub_live_content_request
      live_stream = LiveStream.create
      updater = LiveStreamUpdater.new(live_stream, true)

      stub_any_publishing_api_call_to_return_not_found
      expect(updater.updated?).to be false
      expect(live_stream.state).to be false
    end

    it "handles failure to publish " do
      stub_live_content_request
      live_stream = LiveStream.create
      updater = LiveStreamUpdater.new(live_stream, true)
      expect(updater.updated?).to be true
      expect(live_stream.state).to be true

      stub_any_publishing_api_call_to_return_not_found
      expect(updater.published?).to be false
      expect(live_stream.state).to be false
    end
  end

  describe "#resync" do
    it "database and content item out of sync" do
      #stubbed content item contains { live_stream_enabled: false }
      stub_live_content_request
      live_stream = LiveStream.create.toggle(:state)
      expect(live_stream.state).to be true
      LiveStreamUpdater.new(live_stream).resync
      expect(live_stream.state).to be false
    end

    it "database and content item in sync" do
      stub_live_content_request
      live_stream = LiveStream.create
      expect(live_stream.state).to be false
      LiveStreamUpdater.new(live_stream).resync
      expect(live_stream.state).to be false
    end
  end

  def live_content_item
    File.read(Rails.root.join + "spec/fixtures/coronavirus_content_item.json")
  end

  def stub_live_content_request
    stub_publishing_api_has_item(JSON.parse(live_content_item))
  end

  def landing_page_id
    "774cee22-d896-44c1-a611-e3109cce8eae"
  end
end
