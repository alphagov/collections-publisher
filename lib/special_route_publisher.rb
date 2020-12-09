require "gds_api/publishing_api/special_route_publisher"

class SpecialRoutePublisher
  def initialize
    @publishing_api = Services.publishing_api
    logger = Rails.logger
    @publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(logger: logger, publishing_api: @publishing_api)
  end

  def publish(route)
    default_options = {
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      type: "exact",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "major",
    }

    @publisher.publish(default_options.merge(route))
  end

  def unpublish(content_id, options)
    @publishing_api.unpublish(content_id, options)
  end

  def self.routes
    [
      {
        document_type: "answer",
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness",
        title: "Trade with the UK from 1 January 2021 as a business based in the EU",
        description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
      },
    ]
  end
end
