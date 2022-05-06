require_relative "../publish_organisations_api_route"
require_relative "../special_route_publisher"

namespace :browse_topics do
  desc "Copy all published Mainstream browse pages to Topics"
  task copy_mainstream_browse_pages_to_topics: :environment do
    raise "This rake task is not intended to be run in production" if Rails.env.production?

    CopyMainstreamBrowsePagesToTopics.call(
      MainstreamBrowsePage.where(state: :published),
    )
  end
end
