require "rails_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.describe EmailAlertsUpdater do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:topic) { create(:topic, title: "Child benefit", slug: "child-benefit") }
  let(:successor) { instance_double(ContentItem) }
  let(:successor_base_path) { "/successor-base-path" }
  let(:message) do
    <<~BODY
      This topic has been archived. You will not get any more emails about it.

      You can find more information about this topic at [#{Plek.website_root}#{successor_base_path}](#{Plek.website_root}#{successor_base_path}).
    BODY
  end

  before do
    allow(successor).to receive(:base_path).and_return(successor_base_path)

    email_alert_api_has_subscriber_list_for_topic(
      content_id: topic.content_id,
      list: {
        "title" => "Child benefit",
        "slug" => "tax-credits-and-child-benefit-child-benefit",
      },
    )
  end

  describe ".call" do
    it "calls the email-alert-api with the slug, and generated email body and sender_message_id" do
      allow(SecureRandom).to receive(:uuid).and_return("some-uuid")

      stub_email_alert_api_bulk_unsubscribe_with_message(
        slug: "tax-credits-and-child-benefit-child-benefit",
        body: message,
        sender_message_id: "some-uuid",
      )

      expect {
        described_class.call(
          item: topic,
          successor:,
        )
      }.to_not raise_error
    end

    it "raises an error when there is an error from the email_alert_api" do
      stub_email_alert_api_does_not_have_subscriber_list({ "links" => { topics: %w[ABC] } })

      expect {
        described_class.call(
          item: OpenStruct.new(subscriber_list_search_attributes: { "links" => { topics: %w[ABC] } }, content_id: "ABC"),
          successor:,
        )
      }.to raise_error(GdsApi::HTTPNotFound)
    end
  end
end
