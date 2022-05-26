require_relative "../app/lib/services"

class LinksFetcher
  attr_reader :tag_content_id

  def initialize(tag_content_id)
    @tag_content_id = tag_content_id
  end

  def get_linked_items(link_type)
    publishing_api.get_linked_items(
      tag_content_id,
      link_type: link_type,
      fields: %i[title base_path content_id],
    )
  end

  def get_links
    publishing_api.get_links(tag_content_id)
  end

  def publishing_api
    Services.publishing_api
  end
end
