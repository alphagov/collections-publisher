require "gds_api/publishing_api/special_route_publisher"

class SpecialRoutePublisher
  def initialize
    @publishing_api = Services.publishing_api
    @publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(publishing_api: @publishing_api)
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

  delegate :unpublish, to: :@publishing_api

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
        title: "Handel mit dem Vereinigten Königreich ab 1. Januar 2021 als Unternehmen mit Sitz in der EU",
        description: "Das Vereinigte Königreich ist aus der EU ausgetreten. Am 31. Dezember 2020 wird das Vereinigte Königreich den EU-Binnenmarkt und die Zollunion verlassen. Ab 1. Januar 2021 ändern sich die Regeln für den Handel mit dem Vereinigten Königreich.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.es",
        locale: "es",
        title: "Cómo hacer negocios con el Reino Unido a partir del 1 de enero de 2021 en caso de ser una empresa con sede en la UE",
        description: "El Reino Unido ha salido de la UE. El 31 de diciembre de 2020, el Reino Unido saldrá del mercado único y la unión aduanera de la UE. A partir del 1 de enero de 2021, las normas para comerciar con el Reino Unido van a cambiar.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.fr",
        locale: "fr",
        title: "Travailler avec le Royaume-Uni à partir du 1er janvier 2021 en tant qu'entreprise basée dans l'UE",
        description: "Le Royaume-Uni a quitté l'UE. Le 31 décembre 2020, le Royaume-Uni quittera le marché unique et l'union douanière de l'UE. À partir du 1er janvier 2021, les règles relatives aux échanges commerciaux avec le Royaume-Uni seront modifiées.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.it",
        locale: "it",
        title: "Fai affari con il Regno Unito dal 1° gennaio 2021 in qualità di azienda con sede nell’UE",
        description: "Il Regno Unito ha lasciato l’UE. Il 31 dicembre 2020 il Regno Unito lascerà il mercato unico e l’unione doganale dell’UE. A partire dal 1° gennaio 2021 cambieranno le regole degli scambi commerciali con il Regno Unito.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.nl",
        locale: "nl",
        title: "Handel drijven met het Verenigd Koninkrijk vanuit een in Europa gevestigde onderneming vanaf 1 januari 2021",
        description: "Het Verenigd Koninkrijk heeft de Europese Unie verlaten. Op 31 December 2020 zal het Verenigd Koninkrijk de Europese Interne Markt en de douane-unie van de EU verlaten. Vanaf 1 Januari 2021 veranderen de regels rond handel drijven met het Verenigd Koninkrijk.",
      },
      {
        content_id: "bb986a97-3b8c-4b1a-89bf-2a9f46be9747",
        base_path: "/eubusiness.pl",
        locale: "pl",
        title: "Handel z Wielką Brytanią od 1 stycznia 2021 roku – informacje dla firm z Unii Europejskiej",
        description: "Wielka Brytania opuściła Unię Europejską. 31 grudnia 2020 roku Wielka Brytania opuści jednolity rynek i unię celną UE. Od 1 stycznia 2021 roku zasady handlu z Wielką Brytanią ulegną zmianie.",
      },
    ]
  end
end
