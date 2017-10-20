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

  desc "Publish task list to publishing api"
  task publish_task_list: :environment do
    content_id = "e01e924b-9c7c-4c71-8241-66a575c2f61f"
    params = {
      base_path: "/learn-to-drive-a-car",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "major",
      schema_name: "generic",
      document_type: "task_list",
      title: "Learn to drive a car: step by step",
      description: "Check what you need to do to learn to drive.",
      details: {},
      locale: "en",
      routes: [
        {
          path: "/learn-to-drive-a-car",
          type: "exact"
        }
      ]
    }

    Services.publishing_api.put_content(content_id, params)
    Services.publishing_api.publish(content_id)
  end
end
