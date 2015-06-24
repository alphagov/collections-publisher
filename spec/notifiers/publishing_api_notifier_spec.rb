require "rails_helper"

RSpec.describe PublishingAPINotifier do
  include ContentStoreHelpers
  before { stub_content_store! }

  describe "#send_to_publishing_api" do
    context "for a draft tag" do
      it "sends the presented details to the publishing-api", schema_test: true do
        tag = create(:topic, :draft, slug: 'foo')

        PublishingAPINotifier.send_to_publishing_api(tag)

        expect(stubbed_content_store).to have_draft_content_item_slug('/topic/foo')
        expect(stubbed_content_store.last_updated_item).to be_valid_against_schema('topic')
      end
    end

    context "for a published tag" do
      it "sends the presented details to the publishing-api", schema_test: true do
        tag = create(:topic, :published, slug: 'foo')

        PublishingAPINotifier.send_to_publishing_api(tag)

        expect(stubbed_content_store).to have_content_item_slug('/topic/foo')
        expect(stubbed_content_store.last_updated_item).to be_valid_against_schema('topic')
      end

      it "sends topic redirects to the publishing-api", schema_test: true do
        tag = create(:topic, :published, slug: 'foo')

        create(:redirect, tag: tag,
          original_topic_base_path: '/foo',
          from_base_path: '/foo',
          to_base_path: '/topic/foo',
        )

        PublishingAPINotifier.send_to_publishing_api(tag)

        expect(stubbed_content_store).to have_content_item_slug('/foo')
        expect(stubbed_content_store.last_updated_item).to be_valid_against_schema('redirect')
        expect(stubbed_content_store.last_updated_item[:redirects]).to eql([
          { path: "/foo", type: "exact", destination: "/topic/foo" },
        ])
      end
    end
  end
end
