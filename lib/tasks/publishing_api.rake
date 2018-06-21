require_relative "../publish_organisations_api_route"

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
end
