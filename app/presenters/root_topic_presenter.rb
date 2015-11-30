class RootTopicPresenter

  def initialize(to_be_published)
    @to_be_published = to_be_published
  end

  def content_id
    "76e9abe7-dac8-49f0-bb5e-53e4b0d2cdba"
  end

  def update_type
    "major"
  end

  def draft?
    !@to_be_published
  end

  def archived?
    false
  end
  
  def render_for_publishing_api
    {
      content_id: content_id,
      base_path: '/topic',
      format: "topic",
      title: "Topics",
      locale: 'en',
      public_updated_at: public_updated_at,
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      routes: routes,
      update_type: update_type,
      details: {
        beta: true
      }
    }
  end

  def render_links_for_publishing_api
    {
      links: links
    }
  end

private

  def topics
    Topic.sorted_parents
  end

  def public_updated_at
    if links["children"].empty?
      raise "We can't publish a root topic page without topics"
    else
      topics
        .map(&:updated_at)
        .max
        .iso8601
    end
  end

  def routes
    [
      { path: "/topic", type: "exact" },
    ]
  end

  def links
    {
      "children" => topics.map(&:content_id)
    }
  end
end
