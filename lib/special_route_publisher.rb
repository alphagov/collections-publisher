require "gds_api/publishing_api/special_route_publisher"

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
      ),
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
          content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
          base_path: "/eubusiness",
          title: "Trade with the UK from 1 January 2021 as a business based in the EU",
          description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
        },
      ],
    }
  end
end
