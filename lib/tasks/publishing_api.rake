require_relative "../publish_organisations_api_route"
require_relative "../special_route_publisher"

namespace :publishing_api do
  desc "Send all tags to the publishing-api, skipping any marked as dirty"
  task send_all_tags: :environment do
    TagRepublisher.new.republish_tags(Tag.all)
    RedirectPublisher.new.republish_redirects
  end

  desc "Send all published tags to the publishing-api, skipping any marked as dirty"
  task send_published_tags: :environment do
    TagRepublisher.new.republish_tags(Tag.published)
  end

  desc "Publish the /api/organisations prefix route"
  task publish_organisations_api_route: :environment do
    PublishOrganisationsApiRoute.new.publish
  end

  desc "Publish all special routes"
  task publish_special_routes: :environment do
    publisher = SpecialRoutePublisher.new

    SpecialRoutePublisher.routes.each do |route|
      publisher.publish(route)
    end
  end

  desc "Unpublish all special routes as GONE. Please consider redirecting instead."
  task unpublish_special_routes: :environment do
    publisher = SpecialRoutePublisher.new

    SpecialRoutePublisher.routes.each do |route|
      options = {
        type: "gone",
      }

      publisher.unpublish(route[:content_id], options)
    end
  end

  desc "Publish special route using its base path. It must already be defined in lib/special_route_publisher.rb"
  task :publish_special_route, [:base_path] => :environment do |_task, args|
    route = SpecialRoutePublisher.find_route(args.base_path)

    SpecialRoutePublisher.new.publish(route)
  end

  desc "Patch links for Mainstream Browse Pages"
  task patch_links_for_mainstream_browse_pages: :environment do
    MainstreamBrowsePage.all.each do |page|
      Services.publishing_api.patch_links(
        page.content_id,
        MainstreamBrowsePagePresenter.new(page).render_links_for_publishing_api,
      )

      puts "Patching links for #{page.content_id}..."
    end

    root_page = RootBrowsePagePresenter.new("state" => "published")
    Services.publishing_api.patch_links(
      root_page.content_id,
      root_page.render_links_for_publishing_api,
    )
    puts "Links patched for root page..."
  end

  desc "Patch links for Topics"
  task patch_links_for_topics: :environment do
    Topic.all.each do |page|
      Services.publishing_api.patch_links(
        page.content_id,
        TopicPresenter.new(page).render_links_for_publishing_api,
      )

      puts "Patching links for #{page.content_id}..."
    end

    root_page = RootTopicPresenter.new("state" => "published")
    Services.publishing_api.patch_links(
      root_page.content_id,
      root_page.render_links_for_publishing_api,
    )
    puts "Links patched for root page..."
  end

  desc "Merge mainstream browse pages into topics"
  task merge_mainstream_browse_pages_into_topics: :environment do
    MainstreamBrowsePage.all.each do |page|
      Topic.new(
        title: page.title,
        description: page.description,
        subtopic?: !page.top_level_mainstream_browse_page?
        parent_id: "placeholder" #This is gonna take some thinking...
        links: page.links #This also needs thinking as the children will obviously be browse pages...
        details: {
          "groups" => page.details.groups,
          "internal_name" => page.details.internal_name
        }
      )
    end
  end

end
