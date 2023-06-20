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

  desc "Update redirect for an archived tag"
  task :update_redirect, %i[content_id new_redirect_path] => :environment do |_task, args|
    new_redirect_path = args[:new_redirect_path]
    unless new_redirect_path.present? && new_redirect_path.starts_with?("/")
      raise "new_redirect_path is missing or invalid"
    end

    if Services.content_store.content_item(new_redirect_path)
      tag = Tag.find_by(content_id: args[:content_id])

      raise "No tag can be found for that content id" if tag.blank?

      raise "This task can only be used for archived topics" unless tag.state == "archived" && tag.type == "Topic"

      puts "Updating redirect for #{tag.title}"
      puts "From: '#{tag.redirect_routes.pluck(:to_base_path).uniq.first}'"
      puts "To: '#{new_redirect_path}'"

      redirects = tag.redirect_routes

      redirects.each do |redirect|
        redirect.update!(to_base_path: new_redirect_path)
      end

      tag.reload
      presenter = ArchivedTagPresenter.new(tag)
      ContentItemPublisher.new(presenter).send_to_publishing_api

      puts "Task complete"
    end
  end
end
