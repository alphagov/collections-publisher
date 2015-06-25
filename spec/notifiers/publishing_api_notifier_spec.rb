require "rails_helper"

RSpec.describe PublishingAPINotifier do
  include ContentStoreHelpers

  def browse_page_with_slug(slug, parent=nil)
    create(:mainstream_browse_page,
           slug: slug,
           parent: parent)
  end

  before do
    stub_content_store!
  end

  describe "sending multiples items to the publishing api" do
    #   a     d   - top level
    #  /
    # b           - second level
    before do
      @a = browse_page_with_slug("a")
      @d = browse_page_with_slug("d")
      @b = browse_page_with_slug("b", @a)
    end

    it "sends siblings and the parent when a sibling is added" do
      c = browse_page_with_slug("c", @a)

      ['a', 'a/b', 'a/c'].each do |slug|
        expect(stubbed_content_store).to receive(:put_draft_content_item).with("/browse/#{slug}", anything)
      end

      expect(stubbed_content_store).to_not receive(:put_draft_content_item).with('/browse/d', anything)

      PublishingAPINotifier.send_to_publishing_api(c)
    end

    it "sends the full hierarchy when a parent is added" do
      e = browse_page_with_slug("e")

      ['a', 'a/b', 'd', 'e'].each do |slug|
        expect(stubbed_content_store).to receive(:put_draft_content_item).with("/browse/#{slug}", anything)
      end

      PublishingAPINotifier.send_to_publishing_api(e)
    end

    it "queues dependent tags correctly" do
      Sidekiq::Testing.fake! do
        expect {
          PublishingAPINotifier.send_to_publishing_api(@a)
        }.to change(PublishingAPINotifier::QueueWorker.jobs, :size).by(2)
      end
    end
  end

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
