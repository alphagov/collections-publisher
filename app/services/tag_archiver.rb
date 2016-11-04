# TagArchiver removes a tag from the site. It sets up a redirect for the page
# to its successor and removes the tag from the search engine.
class TagArchiver
  attr_reader :tag, :successor

  def initialize(tag, successor)
    @tag = tag
    @successor = successor
  end

  def archive
    raise "Can't archive parent tags" if tag.can_have_children?

    Tag.transaction do
      update_tag
      setup_redirects
      remove_from_search_index
      republish_tag
    end
  end

private

  def update_tag
    tag.move_to_archive!
  end

  def setup_redirects
    # The redirect will live at the original path of the tag, so the original
    # item in the content store will be replaced by it. The parent topic will
    # no longer expand the item in the `links/children` field because this
    # item will be of the type redirect.

    tag.redirect_routes.create!(
      from_base_path: tag.base_path,
      to_base_path: successor.base_path,
    )

    tag.subroutes.each do |route_suffix|
      # Only setup a redirect to the subroute when the successor also has that
      # route (when redirectinga subtopic to a subtopic), not when redirecting
      # to a parent topic (from /topic/foo/bar to /topic/foo).
      if route_suffix.in?(successor.subroutes)
        to_base_path = "#{successor.base_path}#{route_suffix}"
      else
        to_base_path = successor.base_path
      end

      tag.redirect_routes.create!(
        from_base_path: [tag.base_path, route_suffix].join,
        to_base_path: to_base_path,
      )
    end
  end

  def remove_from_search_index
    Services.rummager.delete_document(
      'edition',
      tag.base_path
    )
  end

  def republish_tag
    presenter = TagPresenter.presenter_for(tag)
    ContentItemPublisher.new(presenter).send_to_publishing_api
  end
end
