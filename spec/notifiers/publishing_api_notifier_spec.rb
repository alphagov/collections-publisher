require "rails_helper"

RSpec.describe PublishingAPINotifier do
  include ContentStoreHelpers

  let(:publishing_api) { instance_double("GdsApi::PublishingApi", :put_content_item => nil, :put_draft_content_item => nil) }

  def browse_page(title, parent=nil)
    create(:mainstream_browse_page,
           title: title,
           parent: parent)
  end

  before do
    stub_content_store!
    allow(CollectionsPublisher).to receive(:services).with(:publishing_api).and_return(publishing_api)
  end

  describe "batch_send_to_publishing_api" do
    #   a     d   - top level
    #  /
    # b           - second level
    before do
      @a = browse_page("a")
      @d = browse_page("d")
      @b = browse_page("b", @a)
    end

    it "sends siblings and the parent when a sibling is added" do
      c = browse_page("c", @a)

      [c, @a, @b].each do |page|
        expect(PublishingAPINotifier).to receive(:send_to_publishing_api).with(page)
      end

      expect(PublishingAPINotifier).to_not receive(:send_to_publishing_api).with(@d)

      PublishingAPINotifier.batch_send_to_publishing_api(c)
    end

    it "sends the full hierarchy when a parent is added" do
      e = browse_page("e")

      [@b, @a, @d, e].each do |page|
        expect(PublishingAPINotifier).to receive(:send_to_publishing_api).with(page)
      end

      PublishingAPINotifier.batch_send_to_publishing_api(e)
    end

    it "queues work correctly" do
      Sidekiq::Testing.fake! do
        expect {
          PublishingAPINotifier.batch_send_to_publishing_api(@a)
        }.to change(PublishingAPINotifier::QueueWorker.jobs, :size).by(3)
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
