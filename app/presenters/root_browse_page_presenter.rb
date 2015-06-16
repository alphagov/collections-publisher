class RootBrowsePagePresenter

  def render_for_publishing_api
    {
      content_id: "8413047e-570a-448b-b8cb-d288a12807dd",
      format: "mainstream_browse_page",
      title: "Browse",
      locale: 'en',
      public_updated_at: Time.now.iso8601,
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      routes: routes,
      update_type: "major",
      links: links,
    }
  end

private

  def routes
    [ {path: "/browse", type: "exact"} ]
  end

  def links
    {
      "top_level_browse_pages" => MainstreamBrowsePage.sorted_parents.map(&:content_id)
    }
  end

end
