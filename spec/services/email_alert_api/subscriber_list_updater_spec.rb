require "rails_helper"
require "gds_api/test_helpers/email_alert_api"
require "gds_api/test_helpers/content_store"

RSpec.describe EmailAlertApi::SubscriberListUpdater do
  include GdsApi::TestHelpers::EmailAlertApi
  include GdsApi::TestHelpers::ContentStore

  let(:topic) { create(:topic, title: "Child benefit", slug: "child-benefit") }

  let(:content_item) do
    instance_double(
      ContentItem,
      base_path:,
      title: "Content Item Title",
      content_id:,
      description: "Content Item Description",
      document_type:,
    )
  end
  let(:base_path) { "/base-path" }
  let(:content_id) { SecureRandom.uuid }
  let(:document_type) { "document_collection" }

  let(:email_alert_api_endpoint) { GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT }
  let(:bulk_unsubscribe_link) { "#{email_alert_api_endpoint}/subscriber-lists/tax-credits-and-child-benefit-child-benefit/bulk-unsubscribe" }
  let(:bulk_migrate_link) { "#{email_alert_api_endpoint}/subscriber-lists/bulk-migrate" }
  let(:expected_unsubscribe_email_message) do
    <<~BODY
      This topic has been archived. You will not get any more emails about it.

      You can find more information about this topic at [#{Plek.website_root}#{base_path}](#{Plek.website_root}#{base_path}).
    BODY
  end

  describe ".call" do
    before do
      email_alert_api_has_subscriber_list_for_topic(
        content_id: topic.content_id,
        list: {
          "title" => "Child benefit",
          "slug" => "tax-credits-and-child-benefit-child-benefit",
        },
      )
    end

    context "bulk unsubscribing specialist topic email subscribers" do
      before do
        allow(SecureRandom).to receive(:uuid).and_return("some-uuid")
      end

      let!(:bulk_unsubscribe_stub) do
        stub_request(:post, bulk_unsubscribe_link)
          .with(body: { body: expected_unsubscribe_email_message, sender_message_id: "some-uuid" })
          .to_return(status: 200)
      end

      it "mapped_specialist_topic_content_id and taxonomy_topic_email_override are both nil" do
        allow(content_item).to receive(:mapped_specialist_topic_content_id).and_return(nil)
        allow(content_item).to receive(:taxonomy_topic_email_override).and_return(nil)

        described_class.call(item: topic, content_item:)
        expect(bulk_unsubscribe_stub).to have_been_requested
        expect(Services.email_alert_api).to receive(:bulk_migrate).never
      end

      it "mapped_specialist_topic_content_id is present but does not match the specialist topic's content id" do
        allow(content_item).to receive(:mapped_specialist_topic_content_id).and_return("i-do-not-match")
        allow(content_item).to receive(:taxonomy_topic_email_override).and_return(nil)

        described_class.call(item: topic, content_item:)
        expect(bulk_unsubscribe_stub).to have_been_requested
        expect(Services.email_alert_api).to receive(:bulk_migrate).never
      end
    end

    context "bulk migrating specialist topic email subscribers" do
      let(:content_id) { "835af2ae-ed12-49f0-9b3c-d6795d028484" }
      let(:base_content_item_data) do
        {
          "content_id" => content_id,
          "details" => {},
          "links" => {},
        }
      end

      it "has a list of exceptional bulk migrations" do
        expect(described_class::EXCEPTIONAL_BULK_MIGRATIONS).to eq({
          "/topic/current/path": "/government/successor/path",
        })
      end

      context "when the source specialist topic matches a special exception" do
        let(:topic) do
          parent = create(:topic, slug: "current")
          create(:topic, parent:, slug: "path")
        end
        let(:document_type) { "document_collection" }

        before do
          stub_email_alert_api_creates_subscriber_list(
            "links" => { "document_collections" => [content_id] },
            "content_id" => content_id,
            "slug" => "document_collection_slug",
          )
        end

        context "when the content item base path does not match the destination path in the special exception" do
          let(:base_path) { "/some/other/path" }

          it "raises SuccessorDestinationError" do
            expect { described_class.call(item: topic, content_item:) }
              .to raise_error(described_class::SuccessorDestinationError)
          end
        end

        context "when the content item base path matches the destination path in the special exception" do
          let(:base_path) { "/government/successor/path" }

          context "when the destination type matches the content item document type" do
            it "migrates to the specified successor topic" do
              expect(Services.email_alert_api).not_to receive(:bulk_unsubscribe)

              bulk_migrate_stub = stub_request(:post, bulk_migrate_link)
                .with(
                  body: {
                    to_slug: "document_collection_slug",
                    from_slug: "tax-credits-and-child-benefit-child-benefit",
                  },
                )
                .to_return(status: 200)
              described_class.call(item: topic, content_item:)
              expect(bulk_migrate_stub).to have_been_requested
            end
          end

          context "when the destination item does not match the content item document type" do
            let(:document_type) { "topic" }

            it "raises SuccessorDestinationError" do
              expect { described_class.call(item: topic, content_item:) }
                .to raise_error(described_class::SuccessorDestinationError)
            end
          end
        end
      end

      context "moving subscribers to a document collection subscriber list" do
        before do
          stub_email_alert_api_creates_subscriber_list(
            "links" => { "document_collections" => [SecureRandom.uuid] },
            "content_id" => content_id,
            "slug" => "document_collection_slug",
          )
        end

        it "content_item has a mapped specialist topic content id that matches the specialist topic's content id" do
          data = base_content_item_data
          data["details"] = { "mapped_specialist_topic_content_id" => topic.content_id }
          content_item = ContentItem.new(data)

          bulk_migrate_stub = stub_request(:post, bulk_migrate_link)
                                .with(body: { to_slug: "document_collection_slug", from_slug: "tax-credits-and-child-benefit-child-benefit" })
                                .to_return(status: 200)

          expect(Services.email_alert_api).to receive(:bulk_unsubscribe).never

          described_class.call(item: topic, content_item:)

          expect(bulk_migrate_stub).to have_been_requested
        end
      end

      context "moving subscribers to a taxonomy topic subscriber list" do
        let(:taxonomy_topic_content_id) { "b20215a9-25fb-4fa6-80a3-42e23f5352c2" }
        let(:taxonomy_topic_base_path) { "/money/dealing-with-hmrc" }
        let(:links_data_for_taxonomy_topic) do
          [
            {
              "content_id" => taxonomy_topic_content_id,
              "base_path" => taxonomy_topic_base_path,
              "document_type" => "taxon",
              "title" => "Dealing with HMRC",
            },
          ]
        end

        before do
          stub_email_alert_api_creates_subscriber_list(
            "links" => { "taxon_tree" => [taxonomy_topic_content_id] },
            "title" => "Dealing with HMRC",
            "url" => taxonomy_topic_base_path,
            "slug" => "taxonomy_topic_slug",
          )
        end

        it "content item has a taxonomy topic email override only" do
          data = base_content_item_data
          base_content_item_data["links"] = { "taxonomy_topic_email_override" => links_data_for_taxonomy_topic }
          content_item = ContentItem.new(data)

          stub_content_store_has_item(taxonomy_topic_base_path)
          bulk_migrate_to_taxonomy_topic_stub = stub_request(:post, bulk_migrate_link)
                                .with(body: { to_slug: "taxonomy_topic_slug", from_slug: "tax-credits-and-child-benefit-child-benefit" })
                                .to_return(status: 200)

          expect(Services.email_alert_api).to receive(:bulk_unsubscribe).never

          described_class.call(item: topic, content_item:)

          expect(bulk_migrate_to_taxonomy_topic_stub).to have_been_requested
        end

        it "content item has a mapped specialist topic content id that matches the specialist topic's content id and also a taxonomy topic email override" do
          data = base_content_item_data
          data["details"] = { "mapped_specialist_topic_content_id" => topic.content_id }
          data["links"] = { "taxonomy_topic_email_override" => links_data_for_taxonomy_topic }
          content_item = ContentItem.new(data)

          stub_content_store_has_item(taxonomy_topic_base_path)
          bulk_migrate_to_taxonomy_topic_stub = stub_request(:post, bulk_migrate_link)
                                .with(body: { to_slug: "taxonomy_topic_slug", from_slug: "tax-credits-and-child-benefit-child-benefit" })
                                .to_return(status: 200)

          expect(Services.email_alert_api).to receive(:bulk_unsubscribe).never

          described_class.call(item: topic, content_item:)

          expect(bulk_migrate_to_taxonomy_topic_stub).to have_been_requested
        end

        it "content item has a taxonomy topic email override that is not in the content store" do
          data = base_content_item_data
          base_content_item_data["links"] = { "taxonomy_topic_email_override" => links_data_for_taxonomy_topic }
          content_item = ContentItem.new(data)

          stub_content_store_does_not_have_item(taxonomy_topic_base_path)

          expect { described_class.call(item: topic, content_item:) }.to raise_error(GdsApi::ContentStore::ItemNotFound)
          expect(Services.email_alert_api).to receive(:bulk_unsubscribe).never
          expect(Services.email_alert_api).to receive(:bulk_migrate).never
        end
      end
    end
  end
end
