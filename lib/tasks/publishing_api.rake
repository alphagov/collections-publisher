require_relative "../publish_organisations_api_route"
require_relative "../special_route_publisher"
require_relative "../../app/presenters/coronavirus_page_presenter"

namespace :publishing_api do
  desc "Publish coronavirus_landing_page to publishing api"
  task publish_coronavirus_landing_page: :environment do
    content_id = "774cee22-d896-44c1-a611-e3109cce8eae"
    params = {
      base_path: "/coronavirus",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "minor",
      document_type: "coronavirus_landing_page",
      title: "Coronavirus (COVID-19): what you need to do",
      description: "Find out about the government response to coronavirus (COVID-19) and what you need to do.",
      details: {},
      locale: "en",
      routes: [
        {
          path: "/coronavirus",
          type: "exact",
        },
      ],
    }
    Services.publishing_api.put_content(content_id, params)
    Services.publishing_api.publish(content_id)
  end

  desc "Publish coronavirus business hub page to publishing api"
  task publish_coronavirus_business_page: :environment do
    url = "https://raw.githubusercontent.com/alphagov/govuk-coronavirus-content/master/content/coronavirus_business_page.yml".freeze
    response = RestClient.get(url)
    if response.code == 200
      corona_content = YAML.safe_load(response.body)["content"]
      payload = CoronavirusPagePresenter.new(corona_content).payload
      content_id = "09944b84-02ba-4742-a696-9e562fc9b29d"
      params = {
          "base_path" => "/coronavirus/business",
          "routes" => [
            {
              "path" => "/coronavirus/business",
              "type" => "exact",
            },
          ],
        }
      Services.publishing_api.put_content(content_id, payload.merge(params))
      Services.publishing_api.publish(content_id)
    else
      puts "Failed to pull content from github. Restclient response: #{response.code}"
    end
  end

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

  desc "Publish finders to the publishing API"
  task publish_finders: :environment do
    Dir[Rails.root + "lib/finders/*.json"].each do |file_path|
      puts "Publishing #{file_path}"

      content_item = JSON.parse(File.read(file_path))
      FinderPublisher.call(content_item)
    end
  end

  desc "Unpublish organisations content finder"
  task unpublish_org_finder: :environment do
    file_path = Rails.root.join("lib/finders/organisation_content.json")

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
      Plek.new.find("publishing-api"),
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )

    logger = Logger.new(STDOUT)

    publisher = SpecialRoutePublisher.new(
      logger: logger,
      publishing_api: publishing_api,
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
      publishing_api: publishing_api,
    )

    SpecialRoutePublisher.routes.each do |_, routes_for_type|
      routes_for_type.each do |route|
        options = {
          type: "gone",
        }

        publisher.unpublish(route[:content_id], options)
      end
    end
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
end
