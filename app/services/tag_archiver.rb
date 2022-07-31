# TagArchiver removes a tag from the site. It sets up a redirect for the page
# to its successor.
class TagArchiver
  attr_reader :tag, :successor

  def initialize(tag, successor)
    @tag = tag
    @successor = successor
  end

  def archive
    raise "Can't archive Level 1 Mainstream browse page" if tag.level_one? && tag.is_a?(MainstreamBrowsePage)

    raise "Can't archive Level 1 Specialist topic with published subtopics" if tag.level_one? && tag.has_not_archived_children?

    Tag.transaction do
      update_tag
      setup_redirects
      republish_tag
      unsubscribe_from_email_alerts if tag.is_a?(Topic) && tag.level_two?
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
      to_base_path = if route_suffix.in?(successor.subroutes)
                       "#{successor.base_path}#{route_suffix}"
                     else
                       successor.base_path
                     end

      tag.redirect_routes.create!(
        from_base_path: [tag.base_path, route_suffix].join,
        to_base_path: to_base_path,
      )
    end
  end

  def republish_tag
    presenter = TagPresenter.presenter_for(tag)
    ContentItemPublisher.new(presenter).send_to_publishing_api
  end

  def unsubscribe_from_email_alerts
    EmailAlertsUnsubscriber.call(
      item: tag,
      body: unsubscribe_email_body,
    )
  end

  def unsubscribe_email_body
    <<~BODY
      This topic has been archived. You will not get any more emails about it.

      You can find more information about this topic at [#{Plek.new.website_root + successor.base_path}](#{Plek.new.website_root + successor.base_path}).
    BODY
  end
end
