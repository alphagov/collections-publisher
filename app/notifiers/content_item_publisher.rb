class ContentItemPublisher
  # Setting the update type to minor means we won't send email alerts for
  # changes to a topic title or description.
  UPDATE_TYPE = 'minor'
  attr_reader :presenter

  delegate :content_id, to: :presenter
  delegate :publishing_api, to: Services

  def initialize(presenter)
    @presenter = presenter
  end

  def send_to_publishing_api
    publishing_api.put_content(content_id, presenter.render_for_publishing_api)

    unless presenter.draft?
      publishing_api.publish(content_id, UPDATE_TYPE)
    end

    unless presenter.archived?
      publishing_api.patch_links(content_id, presenter.render_links_for_publishing_api)
    end
  end
end
