class PublishingAPINotifier
  def self.send_to_publishing_api(tag)
    presenter = TagPresenter.presenter_for(tag)
    publishing_api = CollectionsPublisher.services(:publishing_api)

    if tag.published?
      publishing_api.put_content_item(presenter.base_path, presenter.render_for_publishing_api)
    else
      publishing_api.put_draft_content_item(presenter.base_path, presenter.render_for_publishing_api)
    end
  end
end
