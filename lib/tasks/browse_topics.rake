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

  desc "Copy one published Mainstream browse pages tree to Topics"
  task :copy_mainstream_browse_pages_tree_to_topics, [:mainstream_browse_page_content_id] => :environment do |_task, args|
    raise "This rake task is not intended to be run in production" if Rails.env.production?

    mainstream_browse_page = MainstreamBrowsePage.find_by(content_id: args.mainstream_browse_page_content_id)

    raise "You can only copy over published Mainstream browse pages" unless mainstream_browse_page && mainstream_browse_page.published?

    top_level_mainstream_browse_page = mainstream_browse_page.parent.nil? ? mainstream_browse_page : mainstream_browse_page.parent

    mainstream_browse_pages_in_the_tree = [
      top_level_mainstream_browse_page,
      top_level_mainstream_browse_page.children,
    ].flatten.compact

    CopyMainstreamBrowsePagesToTopics.call(mainstream_browse_pages_in_the_tree)
  end
end
