class RootTopicPresenter
  def initialize(options)
    @state = options['state']
  end

  def content_id
    "76e9abe7-dac8-49f0-bb5e-53e4b0d2cdba"
  end

  def draft?
    @state == 'draft'
  end

  def archived?
    false
  end

  def render_for_publishing_api
    {
      base_path: '/topic',
      schema_name: "topic",
      document_type: "topic",
      title: "Topics",
      locale: 'en',
      public_updated_at: public_updated_at,
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      routes: routes,
      details: {
        beta: true,
        internal_name: "Topic index page",
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
