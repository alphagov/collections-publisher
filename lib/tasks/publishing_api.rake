require_relative "../publish_organisations_api_route"
require_relative "../special_route_publisher"

namespace :publishing_api do
  desc "Send all tags to the publishing-api, skipping any marked as dirty"
  task :send_all_tags => :environment do
    TagRepublisher.new.republish_tags(Tag.all)
    RedirectPublisher.new.republish_redirects
  end

  desc "Send all published tags to the publishing-api, skipping any marked as dirty"
  task :send_published_tags => :environment do
    TagRepublisher.new.republish_tags(Tag.published)
  end

  desc "Publish the /api/organisations prefix route"
  task :publish_organisations_api_route do
    PublishOrganisationsApiRoute.new.publish
  end

  desc 'Publish finders to the publishing API'
  task publish_finders: :environment do
    Dir[Rails.root + "lib/finders/*.json"].each do |file_path|
      puts "Publishing #{file_path}"

      content_item = JSON.parse(File.read(file_path))
      FinderPublisher.call(content_item)
    end
  end

  desc 'Unpublish organisations content finder'
  task unpublish_org_finder: :environment do
    file_path = "#{Rails.root}/lib/finders/organisation_content.json"

    content_item = JSON.parse(File.read(file_path))

    puts "Unpublishing #{content_item['title']}..."

    FinderPublisher.new(content_item).unpublish(
      type: "redirect",
      redirects: [{
        segments_mode: "preserve",
        destination: "/search/all",
        type: "exact",
        path: content_item["base_path"],
      }],
    )
  end

  desc "Publish special routes"
  task publish_special_routes: :environment do
    publishing_api = GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )

    logger = Logger.new(STDOUT)

    publisher = SpecialRoutePublisher.new(
      logger: logger,
      publishing_api: publishing_api
    )

    SpecialRoutePublisher.routes.each do |route_type, routes_for_type|
      routes_for_type.each do |route|
        publisher.publish(route_type, route)
      end
    end
  end

  desc "Unpublish special routes"
  task unpublish_special_routes: :environment do
    publishing_api = Services.publishing_api

    logger = Logger.new(STDOUT)

    publisher = SpecialRoutePublisher.new(
      logger: logger,
      publishing_api: publishing_api
    )

    SpecialRoutePublisher.routes.each do |_, routes_for_type|
      routes_for_type.each do |route|
        options = {
          type: "gone"
        }

        publisher.unpublish(route[:content_id], options)
      end
    end
  end
end
