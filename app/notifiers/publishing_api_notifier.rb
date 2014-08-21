class PublishingAPINotifier
  def self.publish(sector_presenter)
    sector_hash = sector_presenter.render_for_publishing_api

    publishing_api = CollectionsPublisher.services(:publishing_api)
    publishing_api.put_content_item(sector_hash[:base_path], sector_hash)
  end
end
