class RootBrowsePagePresenter
  GDS_CONTENT_ID = "af07d5a5-df63-4ddc-9383-6a666845ebe9".freeze

  def initialize(options)
    @state = options["state"]
  end

  def content_id
    "8413047e-570a-448b-b8cb-d288a12807dd"
  end

  def draft?
    @state == "draft"
  end

  def archived?
    false
  end

  def render_for_publishing_api
    {
      schema_name: "mainstream_browse_page",
      document_type: "mainstream_browse_page",
      base_path: "/browse",
      title: "Browse",
      locale: "en",
      public_updated_at: public_updated_at,
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      routes: routes,
      details: {},
      update_type: "minor",
    }
  end

  def render_links_for_publishing_api
    {
      links: links,
    }
  end

private

  def top_level_browse_pages
    MainstreamBrowsePage.sorted_level_one
  end

  def public_updated_at
    if links["top_level_browse_pages"].empty?
      raise "Top-level pages Array can't be empty"
    else
      top_level_browse_pages
        .map(&:updated_at)
        .max
        .iso8601
    end
  end

  def routes
    [
      { path: "/browse", type: "exact" },
      { path: "/browse.json", type: "exact" },
    ]
  end

  def links
    {
      "top_level_browse_pages" => top_level_browse_pages.map(&:content_id),
      "primary_publishing_organisation" => [GDS_CONTENT_ID],
    }
  end
end
