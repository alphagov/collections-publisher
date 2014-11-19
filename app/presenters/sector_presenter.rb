require 'uri'

class SectorPresenter
  def self.render_for_publishing_api(sector)
    new(sector).render_for_publishing_api
  end

  def initialize(sector)
    @sector = sector
  end

  def render_for_publishing_api
    {
      title: @sector.title,
      base_path: base_path,
      description: @sector.details.description,
      format: "specialist_sector",
      need_ids: [],
      public_updated_at: Time.zone.now.iso8601,
      publishing_app: "collections-publisher",
      rendering_app: "collections", # This will soon change to `collections-frontend`.
      routes: [
        {path: base_path, type: "exact"}
      ],
      redirects: [],
      update_type: "major", # All changes in this app are de facto major for now.
      details: {
        groups: categorized_groups
      }
    }
  end

private

  def base_path
    web_url.path
  end

  def web_url
    @web_url ||= URI.parse(@sector.web_url)
  end

  def categorized_groups
    @sector.ordered_lists.map do |list|
      {
        name: list.name,
        contents: list.tagged_contents.map(&:api_url)
      }
    end
  end

  def uncategorized_contents
    @uncategorized_contents ||= @sector.uncategorized_contents.map(&:api_url)
  end
end
