# TagArchiver removes a tag from the site. It sets op a redirect for the page
# to its successor and removes the tag from the search engine. It does not remove
# the tag from panopticon - that has to be done manually.
class TagArchiver
  attr_reader :tag, :successor

  def initialize(tag, successor)
    @tag = tag
    @successor = successor
  end

  def archive
    return if tag.can_have_children? || tag.tagged_documents.any?

    Tag.transaction do
      remove_tag_from_panopticon
      update_tag
      setup_redirects
      remove_from_search_index
      republish_tag
    end
  end

private

  def remove_tag_from_panopticon
    presenter = TagPresenter.presenter_for(tag)
    tag_hash = presenter.render_for_panopticon
    Services.panopticon.delete_tag!(tag_hash[:tag_type], tag_hash[:tag_id])
  end

  def update_tag
    tag.update!(archived: true)
  end

  def setup_redirects
    # The redirect will live at the original path of the tag, so the original
    # item in the content store will be replaced by it. The parent topic will
    # no longer expand the item in the `links/children` field because this
    # item will be of the type redirect.
    tag.redirects.create!(
      original_tag_base_path: tag.base_path,
      from_base_path: tag.base_path,
      to_base_path: successor.base_path,
    )

    tag.subroutes.each do |route_suffix|
      # Only setup a redirect to the subroute when the successor also has that
      # route (when redirectinga subtopic to a subtopic), not when redirecting
      # to a parent topic (from /topic/foo/bar to /topic/foo).
      to_base_path = route_suffix.in?(successor.subroutes) ?
        "#{successor.base_path}#{route_suffix}" :
        successor.base_path

      tag.redirects.create!(
        original_tag_base_path: tag.base_path,
        from_base_path: [tag.base_path, route_suffix].join,
        to_base_path: to_base_path,
      )
    end
  end

  def remove_from_search_index
    CollectionsPublisher.services(:rummager).delete_document(
      'edition',
      tag.base_path
    )
  end

  def republish_tag
    PublishingAPINotifier.new(tag).send_single_tag_to_publishing_api
  end
end
