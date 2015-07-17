class RootTopicPresenter
  def render_for_publishing_api
    {
      content_id: "76e9abe7-dac8-49f0-bb5e-53e4b0d2cdba",
      format: "topic",
      title: "Topics",
      locale: 'en',
      public_updated_at: public_updated_at,
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      routes: routes,
      update_type: "major",
      links: links,
      details: {
        beta: true
      }
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
