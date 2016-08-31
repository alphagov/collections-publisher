class TaggedDocuments
  include Enumerable
  delegate :each, :empty?, to: :documents
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def documents
    @documents ||= search_result.map do |result|
      Document.new(result["title"], result["base_path"], result["content_id"])
    end
  end

private

  def search_result
    @search_result ||= Services.publishing_api.get_linked_items(
      tag.content_id,
      link_type: filter_name,
      fields: %i[title base_path content_id],
    )
  end

  def filter_name
    if tag.is_a?(Topic)
      :topics
    else
      :mainstream_browse_pages
    end
  end

  Document = Struct.new(:title, :base_path, :content_id)
end
