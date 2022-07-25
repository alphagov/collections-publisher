require "gds_api/test_helpers/email_alert_api"

RSpec.describe EmailAlertsUnsubscriber do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:topic) { create(:topic, title: "Child benefit", slug: "child-benefit") }

  before do
    email_alert_api_has_subscriber_list_for_topic(
      content_id: topic.content_id,
      list: {
        "title" => "Child benefit",
        "slug" => "tax-credits-and-child-benefit-child-benefit",
      },
    )
  end

  describe ".call" do
    it "calls the email-alert-api with the slug" do
      stub_email_alert_api_bulk_unsubscribe(slug: "tax-credits-and-child-benefit-child-benefit")

      expect { described_class.call(item: topic) }.to_not raise_error
    end

    it "calls the email-alert-api with the slug, email body and generated sender_message_id" do
      allow(SecureRandom).to receive(:uuid).and_return("some-uuid")
      stub_email_alert_api_bulk_unsubscribe_with_message(
        slug: "tax-credits-and-child-benefit-child-benefit",
        body: "We archived this, soz",
        sender_message_id: "some-uuid",
      )

      expect {
        described_class.call(
          item: topic,
          body: "We archived this, soz",
        )
      }.to_not raise_error
    end

    it "calls the email-alert-api with govuk_request_id when passed in" do
      allow(SecureRandom).to receive(:uuid).and_return("some-uuid")
      stub_email_alert_api_bulk_unsubscribe_with_message(
        slug: "tax-credits-and-child-benefit-child-benefit",
        govuk_request_id: "govuk-request-id-123",
        body: "We archived this, soz",
        sender_message_id: "some-uuid",
      )

      expect {
        described_class.call(
          item: topic,
          body: "We archived this, soz",
          govuk_request_id: "govuk-request-id-123",
        )
      }.to_not raise_error
    end

    it "raises an error when there is an error from the email_alert_api" do
      stub_email_alert_api_does_not_have_subscriber_list({ "links" => { topics: %w[ABC] } })

      expect {
        described_class.call(item: OpenStruct.new(subscriber_list_search_attributes: { "links" => { topics: %w[ABC] } }, content_id: "ABC"))
      }.to raise_error(GdsApi::HTTPNotFound)
    end
  end
end
