module PublishingAPIHelpers
  def check_lists_were_sent_to_publishing_api(sector_slug:, lists:)
    groups_for_publishing_api = lists.map { |list|
      {
        name: list[:name],
        contents: list[:content].map {|slug| content_api_url(slug: slug) }
      }
    }

    expect(CollectionsPublisher.services(:publishing_api)).to have_received(:put_content_item)
      .with("/browse/#{sector_slug}", hash_including(
        details: {
          groups: groups_for_publishing_api
        }
      ))
  end
end

World(PublishingAPIHelpers)
