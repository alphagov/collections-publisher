namespace :step_nav do
  desc "Unpublish /get-a-divorce step navigation to publishing api"
  task unpublish_get_a_divorce: :environment do
    content_id = "3d1279d9-73e9-4871-8b82-7389955b4c1b"
    Services.publishing_api.unpublish(content_id, type: "redirect", alternative_path: "/divorce")
  end

  desc "Publish /get-a-divorce step navigation publishing api"
  task publish_get_a_divorce: :environment do
    content_id = "3d1279d9-73e9-4871-8b82-7389955b4c1b"
    params = {
      base_path: "/get-a-divorce",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "major",
      schema_name: "generic",
      document_type: "step_by_step_nav",
      title: "Get a divorce: step by step",
      description: "Grounds for divorce, child arrangements, money and "\
        "property, file for divorce, D8 form, apply for a decree nisi and "\
        "decree absolute.",
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
