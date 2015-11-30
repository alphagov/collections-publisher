module ContentStoreHelpers

  RSpec::Matchers.define :have_content_item_slug do |expected_slug|
    match do |stubbed_content_store|
      stubbed_content_store.stored_published_slugs.include?(expected_slug)
    end
  end

  RSpec::Matchers.define :have_draft_content_item_slug do |expected_slug|
    match do |stubbed_content_store|
      stubbed_content_store.stored_draft_slugs.include?(expected_slug)
    end
  end

  def stub_content_store!
    @stubbed_content_store = FakeContentStore.new
    allow(Services).to receive(:publishing_api)
      .and_return(@stubbed_content_store)
  end

  def stubbed_content_store
    @stubbed_content_store
  end

  class FakeContentStore
    attr_reader :stored_draft_slugs,
                :stored_published_slugs,
                :last_updated_item,
                :stored_links

    def initialize
      @stored_draft_slugs = []
      @stored_published_slugs = []
      @stored_items = {}
      @stored_links = {}
    end

    def put_content(content_id, item)
      @stored_draft_slugs << item[:base_path]
      @last_updated_item = item
      @stored_items[content_id] = item
    end

    def publish(content_id, update_type)
      item = @stored_items[content_id]
      raise "Item #{content_id} not previously written to content store as draft" if item.nil?
      @stored_published_slugs << item[:base_path]
    end

    def put_links(content_id, links)
      item = @stored_items[content_id]
      raise "Item #{content_id} not previously written to content store as draft" if item.nil?
      @stored_links[content_id] = links
    end

    def item_by_content_id(content_id)
      @stored_items.fetch(content_id)
    end
  end
end
