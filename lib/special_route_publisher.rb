require 'gds_api/publishing_api/special_route_publisher'

class SpecialRoutePublisher
  def initialize(publisher_options)
    @publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(publisher_options)
  end

  def publish(route_type, route)
    @publisher.publish(
      route.merge(
        format: "special_route",
        publishing_app: "collections-publisher",
        rendering_app: "collections",
        type: route_type,
        public_updated_at: Time.zone.now.iso8601,
        update_type: "major",
      )
    )
  end

  def self.routes
    {
      prefix: [
        {
          content_id: "ecb55f9d-0823-43bd-a116-dbfab2b76ef9",
          base_path: "/prepare-uk-leaving-eu",
          title: "Prepare for the UK leaving the EU",
          description: "How to prepare for Brexit in March 2019 if you're a British citizen or have indefinite leave to remain in the UK.",
        },
      ]
    }
  end
end
