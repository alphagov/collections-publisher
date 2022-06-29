RSpec.describe EmailAlertsUnsubscriber do

  describe ".call" do
    it "calls the email-alert-api with the slug" do
      stub_email_alert_api_bulk_unsubscribe(slug: "funding-programmes")

      expect { described_class.call(slug: "funding-programmes") }.to_not raise_error
    end

    it "calls the email-alert-api with the slug, email body and generated sender_message_id" do
      allow(SecureRandom).to receive(:uuid).and_return("some-uuid")
      stub_email_alert_api_bulk_unsubscribe_with_message(
        slug: "secondments-with-government",
        body: "We archived this, soz",
        sender_message_id: "some-uuid",
      )

      expect {
        described_class.call(
          slug: "secondments-with-government",
          body: "We archived this, soz",
        )
      }.to_not raise_error
    end

    it "calls the email-alert-api with govuk_request_id when passed in" do
      allow(SecureRandom).to receive(:uuid).and_return("some-uuid")
      stub_email_alert_api_bulk_unsubscribe_with_message(
        slug: "secondments-with-government",
        govuk_request_id: "govuk-request-id-123",
        body: "We archived this, soz",
        sender_message_id: "some-uuid",
      )

      expect {
        described_class.call(
          slug: "secondments-with-government",
          body: "We archived this, soz",
          govuk_request_id: "govuk-request-id-123",
        )
      }.to_not raise_error
    end

    it "raises an error when there is an error from the email_alert_api" do
      stub_email_alert_api_bulk_unsubscribe_bad_request(slug: "not a valid slug")

      expect { described_class.call(slug: "not a valid slug") }.to raise_error(GdsApi::InvalidUrl)
    end
  end
end
