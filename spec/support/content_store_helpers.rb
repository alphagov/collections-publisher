module ContentStoreHelpers
  RSpec::Matchers.define :have_content_item_slug do |expected_slug|
    match do |stubbed_content_store|
      stubbed_content_store.stored_slugs.include?(expected_slug)
    end
  end

  RSpec::Matchers.define :have_draft_content_item_slug do |expected_slug|
    match do |stubbed_content_store|
      stubbed_content_store.stored_draft_slugs.include?(expected_slug)
    end
  end

  def stub_content_store!
    @stubbed_content_store = FakeContentStore.new
    allow(CollectionsPublisher).to receive(:services)
      .with(:publishing_api)
      .and_return(@stubbed_content_store)
  end

  def stubbed_content_store
    @stubbed_content_store
  end

  class FakeContentStore
    attr_reader :stored_slugs,
                :stored_draft_slugs,
                :last_updated_item

    def initialize
      @stored_slugs = []
      @stored_draft_slugs = []
      @stored_items = {}
    end

    def put_content_item(slug, item)
      @stored_slugs << slug
      @last_updated_item = item
      @stored_items[slug] = item
    end

    def put_draft_content_item(slug, item)
      @stored_draft_slugs << slug
      @last_updated_item = item
      @stored_items[slug] = item
    end

    def item_with_slug(slug)
      @stored_items.fetch(slug)
    end
  end
end
