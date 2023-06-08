require "rails_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.describe EmailAlertsUpdater do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:topic) { create(:topic, title: "Child benefit", slug: "child-benefit") }
  let(:email_alert_api_endpoint) { GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT }

  describe ".call" do
    let(:successor) { instance_double(ContentItem) }
    let(:successor_base_path) { "/successor-base-path" }
    let(:expected_unsubscribe_email_message) do
      <<~BODY
        This topic has been archived. You will not get any more emails about it.

        You can find more information about this topic at [#{Plek.website_root}#{successor_base_path}](#{Plek.website_root}#{successor_base_path}).
      BODY
    end
    let(:bulk_unsubscribe_link) { "#{email_alert_api_endpoint}/subscriber-lists/tax-credits-and-child-benefit-child-benefit/bulk-unsubscribe" }
    let(:bulk_migrate_link) { "#{email_alert_api_endpoint}/subscriber-lists/bulk-migrate" }

    before do
      allow(successor).to receive(:base_path).and_return(successor_base_path)
      allow(SecureRandom).to receive(:uuid).and_return("some-uuid")
      email_alert_api_has_subscriber_list_for_topic(
        content_id: topic.content_id,
        list: {
          "title" => "Child benefit",
          "slug" => "tax-credits-and-child-benefit-child-benefit",
        },
      )
    end

    context "when the successor has a mapped specialist topic content id that does not match the item's content id" do
      before do
        allow(successor).to receive(:mapped_specialist_topic_content_id).and_return("e3c4f270-044b-11ee-be56-0242ac120002")
      end

      it "makes a call the email-alert-api bulk unsubscribe endpoint with the slug, and generated email body and sender_message_id" do
        bulk_unsubscribe_stub = stub_request(:post, bulk_unsubscribe_link)
                                  .with(body: { body: expected_unsubscribe_email_message, sender_message_id: "some-uuid" })
                                  .to_return(status: 200)

        expect(Services.email_alert_api).to receive(:bulk_migrate).never

        described_class.call(item: topic, successor:)
        expect(bulk_unsubscribe_stub).to have_been_requested
      end
    end

    context "when the success has no mapped specialist topic content id" do
      before do
        allow(successor).to receive(:mapped_specialist_topic_content_id).and_return(nil)
      end

      it "makes a call the email-alert-api bulk unsubscribe endpoint with the slug, and generated email body and sender_message_id" do
        bulk_unsubscribe_stub = stub_request(:post, bulk_unsubscribe_link)
                                  .with(body: { body: expected_unsubscribe_email_message, sender_message_id: "some-uuid" })
                                  .to_return(status: 200)

        expect(Services.email_alert_api).to receive(:bulk_migrate).never

        described_class.call(item: topic, successor:)
        expect(bulk_unsubscribe_stub).to have_been_requested
      end
    end

    context "when the successor has the same mapped specialist topic id as the topic it is replacing" do
      let(:successor_data) do
        {
          "title" => "Successor document collection",
          "base_path" => successor_base_path,
          "content_id" => "835af2ae-ed12-49f0-9b3c-d6795d028484",
          "document_type" => "document_collection",
          "description" => "description for Successor document collection",
          "details" => {
            "mapped_specialist_topic_content_id" => topic.content_id,
          },
        }
      end
      let(:successor) { ContentItem.new(successor_data) }

      before do
        stub_email_alert_api_creates_subscriber_list(
          "title" => "Successor document collection",
          "links" => { "document_collections" => [SecureRandom.uuid] },
          "content_id" => "835af2ae-ed12-49f0-9b3c-d6795d028484",
          "description" => "description for Successor document collection",
          "slug" => "slug",
        )
      end

      it "makes a call the email-alert-api bulk migrate endpoint with the slug of the subscriber list of the document collection" do
        bulk_migrate_stub = stub_request(:post, bulk_migrate_link)
                              .with(body: { to_slug: "slug", from_slug: "tax-credits-and-child-benefit-child-benefit" })
                              .to_return(status: 200)
        expect(Services.email_alert_api).to receive(:bulk_unsubscribe).never

        described_class.call(item: topic, successor:)
        expect(bulk_migrate_stub).to have_been_requested
      end
    end
  end
end
