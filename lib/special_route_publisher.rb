require 'gds_api/publishing_api/special_route_publisher'

class SpecialRoutePublisher
  def initialize(publisher_options)
    @publishing_api = publisher_options[:publishing_api]
    @publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(publisher_options)
  end

  def publish(route_type, route)
    @publisher.publish(
      route.merge(
        publishing_app: "collections-publisher",
        rendering_app: "collections",
        type: route_type,
        public_updated_at: Time.zone.now.iso8601,
        update_type: "major",
      )
    )
  end

  def unpublish(content_id, options)
    @publishing_api.unpublish(content_id, options)
  end

  def self.routes
    {
      prefix: [
        {
          document_type: "answer",
          content_id: "ecb55f9d-0823-43bd-a116-dbfab2b76ef9",
          base_path: "/prepare-eu-exit",
          title: "Prepare for EU Exit if you live in the UK",
          description: "How Brexit affects you - visiting Europe, buying things, studying, family law.",
        },
      ]
    }
  end
end
