class TagBroadcaster
  def self.broadcast(browse_page)
    PublishingAPINotifier.notify(browse_page)
  end
end
