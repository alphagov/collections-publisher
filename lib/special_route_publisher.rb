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
      update_type: "major",
    }

    @publisher.publish(default_options.merge(route))
  end

  def unpublish(content_id, options)
    @publishing_api.unpublish(content_id, options)
  end

  def self.find_route(base_path)
    routes.find { |route| route[:base_path] == base_path }
  end

  def self.routes
    [
      {
        document_type: "answer",
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness",
        locale: "en",
        title: "Trade with the UK from 1 January 2021 as a business based in the EU",
        description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.de",
        locale: "de",
        title: "Trade with the UK from 1 January 2021 as a business based in the EU",
        description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.es",
        locale: "es",
        title: "Trade with the UK from 1 January 2021 as a business based in the EU",
        description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.fr",
        locale: "fr",
        title: "Trade with the UK from 1 January 2021 as a business based in the EU",
        description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.it",
        locale: "it",
        title: "Trade with the UK from 1 January 2021 as a business based in the EU",
        description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.nl",
        locale: "nl",
        title: "Trade with the UK from 1 January 2021 as a business based in the EU",
        description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.pl",
        locale: "pl",
        title: "Trade with the UK from 1 January 2021 as a business based in the EU",
        description: "The UK has left the EU. On 31 December 2020 the UK will leave the EU single market and customs union. From 1 January 2021 the rules for trading with the UK will change.",
      },
    ]
  end
end
