class PublishingAPINotifier
  def self.send_to_publishing_api(tag)
    unless tag.published?
      raise ArgumentError, "Cannot publish draft tag"
    end
    presenter = TagPresenter.presenter_for(tag)
    publishing_api = CollectionsPublisher.services(:publishing_api)
    publishing_api.put_content_item(presenter.base_path, presenter.render_for_publishing_api)
    tag.mark_as_clean!
  end
end
