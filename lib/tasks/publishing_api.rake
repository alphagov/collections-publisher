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
      description: "Learn to drive a car in the UK - get a provisional licence, take driving lessons, prepare for your theory test, book your practical test.",
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

  desc "Publish /end-a-civil-partnership task list to publishing api"
  task publish_end_a_civil_partnership_task_list: :environment do
    content_id = "b6ee74ca-123c-4e89-82b5-369be9362159"
    params = {
      base_path: "/end-a-civil-partnership",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "major",
      schema_name: "generic",
      document_type: "task_list",
      title: "End a civil partnership: step by step",
      description: "How to end your civil partnership if you’re in England or Wales.",
      details: {},
      locale: "en",
      routes: [
        {
          path: "/end-a-civil-partnership",
          type: "exact"
        }
      ]
    }

    Services.publishing_api.put_content(content_id, params)
    Services.publishing_api.publish(content_id)
  end

  desc "Publish /get-a-divorce task list to publishing api"
  task publish_get_a_divorce_task_list: :environment do
    content_id = "3d1279d9-73e9-4871-8b82-7389955b4c1b"
    params = {
      base_path: "/get-a-divorce",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "major",
      schema_name: "generic",
      document_type: "task_list",
      title: "Get a divorce: step by step",
      description: "How to file for divorce if you’re in England or Wales.",
      details: {},
      locale: "en",
      routes: [
        {
          path: "/get-a-divorce",
          type: "exact"
        }
      ]
    }

    Services.publishing_api.put_content(content_id, params)
    Services.publishing_api.publish(content_id)
  end
end
