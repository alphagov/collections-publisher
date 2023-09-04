require "rails_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.describe EmailAlertApi::SubscriberListUpdater do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:topic) { create(:topic, title: "Child benefit", slug: "child-benefit") }

  let(:successor) { instance_double(ContentItem) }
  let(:successor_base_path) { "/successor-base-path" }

  let(:email_alert_api_endpoint) { GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT }
  let(:bulk_unsubscribe_link) { "#{email_alert_api_endpoint}/subscriber-lists/tax-credits-and-child-benefit-child-benefit/bulk-unsubscribe" }
  let(:bulk_migrate_link) { "#{email_alert_api_endpoint}/subscriber-lists/bulk-migrate" }
  let(:expected_unsubscribe_email_message) do
    <<~BODY
      This topic has been archived. You will not get any more emails about it.

      You can find more information about this topic at [#{Plek.website_root}#{successor_base_path}](#{Plek.website_root}#{successor_base_path}).
    BODY
  end

  describe ".call" do
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

    context "bulk unsubscribing specialist topic email subscribers" do
      let!(:bulk_unsubscribe_stub) do
        stub_request(:post, bulk_unsubscribe_link)
          .with(body: { body: expected_unsubscribe_email_message, sender_message_id: "some-uuid" })
          .to_return(status: 200)
      end

      it "mapped_specialist_topic_content_id is nil" do
        allow(successor).to receive(:mapped_specialist_topic_content_id).and_return(nil)

        described_class.call(item: topic, successor:)
        expect(bulk_unsubscribe_stub).to have_been_requested
        expect(Services.email_alert_api).to receive(:bulk_migrate).never
      end

      it "mapped_specialist_topic_content_id is present but does not match specialist topic content id" do
        allow(successor).to receive(:mapped_specialist_topic_content_id).and_return("i-do-not-match")

        described_class.call(item: topic, successor:)
        expect(bulk_unsubscribe_stub).to have_been_requested
        expect(Services.email_alert_api).to receive(:bulk_migrate).never
      end
    end

    context "bulk migrating specialist topic email subscribers" do
      let(:successor_content_id) { "835af2ae-ed12-49f0-9b3c-d6795d028484" }
      let(:base_content_item_data) do
        {
          "content_id" => successor_content_id,
          "details" => {},
          "links" => {},
        }
      end

      context "moving subscribers to a document collection subscriber list" do
        before do
          stub_email_alert_api_creates_subscriber_list(
            "links" => { "document_collections" => [SecureRandom.uuid] },
            "content_id" => successor_content_id,
            "slug" => "document_collection_slug",
          )
        end

        it "successor has a mapped specialist topic content id that matches the specialist topic's content id" do
          data = base_content_item_data
          data["details"] = { "mapped_specialist_topic_content_id" => topic.content_id }
          successor = ContentItem.new(data)

          bulk_migrate_stub = stub_request(:post, bulk_migrate_link)
                                .with(body: { to_slug: "document_collection_slug", from_slug: "tax-credits-and-child-benefit-child-benefit" })
                                .to_return(status: 200)

          expect(Services.email_alert_api).to receive(:bulk_unsubscribe).never

          described_class.call(item: topic, successor:)

          expect(bulk_migrate_stub).to have_been_requested
        end
      end
    end
  end
end
