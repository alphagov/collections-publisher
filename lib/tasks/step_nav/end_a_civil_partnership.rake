namespace :step_nav do
  desc "Unpublish /end-a-civil-partnership step navigation to publishing api"
  task unpublish_end_a_civil_partnership: :environment do
    content_id = "b6ee74ca-123c-4e89-82b5-369be9362159"
    Services.publishing_api.unpublish(content_id, type: "redirect", alternative_path: "/end-civil-partnership")
  end

  desc "Publish /end-a-civil-partnership step navigation to publishing api"
  task publish_end_a_civil_partnership: :environment do
    content_id = "b6ee74ca-123c-4e89-82b5-369be9362159"
    params = {
      base_path: "/end-a-civil-partnership",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "major",
      schema_name: "generic",
      document_type: "step_by_step_nav",
      title: "End a civil partnership: step by step",
      description: "Grounds for ending a partnership, child arrangements, "\
        "money and property, file an application, D8 form, apply for a consent "\
        "order and final order",
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
end
