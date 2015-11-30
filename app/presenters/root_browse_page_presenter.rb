class RootBrowsePagePresenter
  def initialize(to_be_published)
    @to_be_published = to_be_published
  end

  def content_id
    "8413047e-570a-448b-b8cb-d288a12807dd"
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
      format: "mainstream_browse_page",
      base_path: '/browse',
      title: "Browse",
      locale: 'en',
      public_updated_at: public_updated_at,
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      routes: routes,
      update_type: update_type,
      links: links,
    }
  end

  def render_links_for_publishing_api
    {
      links: links
    }
  end

private

  def top_level_browse_pages
    MainstreamBrowsePage.sorted_parents
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
      {path: "/browse", type: "exact"},
      {path: "/browse.json", type: "exact"},
    ]
  end

  def links
    {
      "top_level_browse_pages" => top_level_browse_pages.map(&:content_id)
    }
  end
end
