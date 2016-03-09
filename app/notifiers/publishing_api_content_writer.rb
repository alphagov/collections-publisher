class PublishingApiContentWriter
  # Setting the update type to minor means we won't send email alerts for
  # changes to a topic title or description.
  UPDATE_TYPE = 'minor'

  def self.write(presenter)
    publishing_api = Services.publishing_api
    publishing_api.put_content(presenter.content_id, presenter.render_for_publishing_api)
    publishing_api.publish(presenter.content_id, UPDATE_TYPE) unless presenter.draft?
    publishing_api.patch_links(presenter.content_id, presenter.render_links_for_publishing_api) unless presenter.archived?
  end
end
