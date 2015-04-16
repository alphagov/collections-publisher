Before('@mock-publishing-api') do
  CollectionsPublisher.services(:publishing_api, double(:publishing_api, put_content_item: nil))
end
