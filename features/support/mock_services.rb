Before('@mock-publishing-api') do
  CollectionsPublisher.services(:publishing_api, double(:publishing_api, put_content_item: nil))
end

Before('@mock-panopticon') do
  CollectionsPublisher.services(:panopticon, double(:panopticon,
    create_tag: nil,
    put_tag: nil,
  ))
end
