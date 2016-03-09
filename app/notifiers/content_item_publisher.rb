class ContentItemPublisher
  # Setting the update type to minor means we won't send email alerts for
  # changes to a topic title or description.
  DEFAULT_UPDATE_TYPE = 'minor'
  attr_reader :presenter, :update_type

  delegate :content_id, to: :presenter
  delegate :publishing_api, to: Services

  def initialize(presenter, update_type: DEFAULT_UPDATE_TYPE)
    @presenter = presenter
    @update_type = update_type
  end

  def send_to_publishing_api
    publishing_api.put_content(content_id, presenter.render_for_publishing_api)

    unless presenter.draft?
      publishing_api.publish(content_id, update_type)
    end

    unless presenter.archived?
      publishing_api.patch_links(content_id, presenter.render_links_for_publishing_api)
    end
  end
end
