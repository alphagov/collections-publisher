require "rails_helper"

RSpec.describe PublishingAPINotifier do
  include ContentStoreHelpers

  let(:root_browse_page_content_id)       { RootBrowsePagePresenter.new(true).content_id }
  let(:root_topic_content_id)             { RootTopicPresenter.new.content_id }

  def browse_page_with_slug(slug, parent = nil)
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
      [@a, @b, c].each do |item|
        expect(stubbed_content_store).to receive(:put_content).with(item.content_id, anything).and_call_original
      end
      expect(stubbed_content_store).to_not receive(:put_content).with(root_browse_page_content_id, anything)
      expect(stubbed_content_store).to_not receive(:put_content).with(@d.content_id, anything)

      PublishingAPINotifier.send_to_publishing_api(c)
      expect(stubbed_content_store.stored_draft_slugs).to eq(["/browse/a/c", "/browse/a/b", "/browse/a"])
    end

    it 'sends links to the publishing-api for all dependents' do
      c = browse_page_with_slug("c", @a)

      PublishingAPINotifier.send_to_publishing_api(c)
      links_for_c = stubbed_content_store.stored_links[c.content_id]
      expect(links_for_c[:links]['top_level_browse_pages']).to include(@a.content_id)
      expect(links_for_c[:links]['top_level_browse_pages']).to include(@d.content_id)
      expect(links_for_c[:links]['second_level_browse_pages']).to include(@b.content_id)
      expect(links_for_c[:links]['second_level_browse_pages']).to include(c.content_id)
    end

    it "sends the full hierarchy when a parent is added" do
      e = browse_page_with_slug("e")
      [@a, @b, @d, e].each do |item|
        expect(stubbed_content_store).to receive(:put_content).with(item.content_id, anything).and_call_original
      end
      expect(stubbed_content_store).to receive(:put_content).with(root_browse_page_content_id, anything).and_call_original

      PublishingAPINotifier.send_to_publishing_api(e)
      expect(stubbed_content_store.stored_draft_slugs).to eq(["/browse/e", "/browse/a", "/browse/d", "/browse/a/b", "/browse"])
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
    it "sends Root Browse page content_id for top level mainstream browse pages" do
      tag = create(:mainstream_browse_page, :published, slug: 'foo')

      PublishingAPINotifier.send_to_publishing_api(tag)

      expect(stubbed_content_store).to have_content_item_slug('/browse')
    end

    it "sends /browse for top level mainstream browse pages" do
      tag = create(:topic, :published, slug: 'foo')

      PublishingAPINotifier.send_to_publishing_api(tag)

      expect(stubbed_content_store).to have_content_item_slug('/topic')
    end

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

        create(:redirect_route,
          from_base_path: '/foo',
          to_base_path: '/topic/foo',
          tag: tag,
        )

        PublishingAPINotifier.send_to_publishing_api(tag)
        content_item = stubbed_content_store.item_by_content_id(tag.content_id)
        expect(content_item).to be_valid_against_schema('topic')
        expect(content_item[:redirects]).to eq([{ path: "/foo", destination: "/topic/foo", type: "exact" }])
      end
    end
  end
end
