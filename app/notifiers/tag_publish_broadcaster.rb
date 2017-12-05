class TagPublishBroadcaster
  def self.broadcast(topic_or_browse_page)
    PublishingAPINotifier.notify(topic_or_browse_page)
  end
end
