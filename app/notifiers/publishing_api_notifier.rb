class PublishingAPINotifier
  def self.notify(tag)
    presenter = TagPresenter.presenter_for(tag)
    ContentItemPublisher.new(presenter).send_to_publishing_api

    DependentTagPublishWorker.perform_async(tag.id)
  end
end
