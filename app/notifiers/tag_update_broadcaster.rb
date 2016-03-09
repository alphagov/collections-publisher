class TagUpdateBroadcaster
  def self.broadcast(topic_or_browse_page)
    PanopticonNotifier.update_tag(TagPresenter.presenter_for(topic_or_browse_page))
    PublishingAPINotifier.notify(topic_or_browse_page)
    RummagerNotifier.new(topic_or_browse_page).notify
  end
end
