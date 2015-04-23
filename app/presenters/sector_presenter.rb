require 'uri'

class SectorPresenter
  def self.render_for_publishing_api(topic)
    new(topic).render_for_publishing_api
  end

  def initialize(topic)
    @topic = topic
  end

  def render_for_publishing_api
    {
      title: @topic.title,
      description: @topic.description,
      format: "specialist_sector",
      need_ids: [],
      public_updated_at: Time.zone.now.iso8601,
      publishing_app: "collections-publisher",
      rendering_app: "collections", # This will soon change to `collections-frontend`.
      routes: [
        {path: base_path, type: "prefix"}
      ],
      redirects: [],
      update_type: "major", # All changes in this app are de facto major for now.
      details: {
        groups: categorized_groups
      }
    }
  end

  def base_path
    @topic.base_path
  end

private

  def categorized_groups
    @topic.lists.ordered.map do |list|
      {
        name: list.name,
        contents: list.tagged_list_items.map(&:api_url)
      }
    end
  end
end
