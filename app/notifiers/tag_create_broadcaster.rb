class TagCreateBroadcaster
  def self.broadcast(topic_or_browse_page)
    PanopticonNotifier.create_tag(TagPresenter.presenter_for(topic_or_browse_page))
    PublishingAPINotifier.send_to_publishing_api(topic_or_browse_page)
  end
end
