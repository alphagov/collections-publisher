class CoronavirusPagePresenter
  attr_reader :description, :details, :title

  BASE_PATH = "/coronavirus".freeze

  def initialize(corona_content)
    @title = corona_content.delete("title")
    @description = corona_content.delete("meta_description")
    @details = corona_content
  end

  def payload
    {
      "base_path" => BASE_PATH,
      "title" => title,
      "description" => description,
      "document_type" => "coronavirus_landing_page",
      "schema_name" => "coronavirus_landing_page",
      "details" => details,
      "links" => {},
      "locale" => "en",
      "rendering_app" => "collections",
      "publishing_app" => "collections-publisher",
      "routes" => [{ "path" => BASE_PATH, "type" => "exact" }],
    }
  end
end
