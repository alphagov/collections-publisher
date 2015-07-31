class TaggedDocuments
  PAGE_SIZE_TO_GET_EVERYTHING = 10_000

  include Enumerable
  delegate :each, to: :documents
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def documents
    @documents ||= search_result["results"].map do |result|
      Document.new(result["title"], result["link"])
    end
  end

private

  def search_result
    @search_result ||= CollectionsPublisher.services(:rummager).unified_search({
      :start => 0,
      :count => PAGE_SIZE_TO_GET_EVERYTHING,
      filter_name => [tag.full_slug],
      :fields => %w[title link],
    })
  end

  def filter_name
    if tag.is_a?(Topic)
      :filter_specialist_sectors
    else
      :filter_mainstream_browse_pages
    end
  end

  Document = Struct.new(:title, :base_path)
end
