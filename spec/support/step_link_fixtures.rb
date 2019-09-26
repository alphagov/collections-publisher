module StepLinkFixtures
  def step_link_fixtures_return_data
    {
      "/good/stuff" => "fd6b1901d-b925-47c5-b1ca-1e52197097e1",
      "/also/good/stuff" => "fd6b1901d-b925-47c5-b1ca-1e52197097e2",
      "/not/as/great" => "fd6b1901d-b925-47c5-b1ca-1e52197097e3",
    }
  end

  def step_link_fixtures_content_items
    [
      basic_content_item(
        title: "Good Stuff",
        base_path: "/good/stuff",
        content_id: "fd6b1901d-b925-47c5-b1ca-1e52197097e1",
        publishing_app: "publisher",
        schema_name: "guide",
      ),
      basic_content_item(
        title: "Also Good Stuff",
        base_path: "/also/good/stuff",
        content_id: "fd6b1901d-b925-47c5-b1ca-1e52197097e2",
        publishing_app: "publisher",
        schema_name: "guide",
      ),
      basic_content_item(
        title: "Not as Great",
        base_path: "/not/as/great",
        content_id: "fd6b1901d-b925-47c5-b1ca-1e52197097e3",
        publishing_app: "publisher",
        schema_name: "guide",
      ),
    ]
  end

  def basic_content_item(title:, base_path:, content_id:, publishing_app:, schema_name:)
    {
      "title": title,
      "base_path": base_path,
      "content_id": content_id,
      "publishing_app": publishing_app,
      "schema_name": schema_name,
    }.with_indifferent_access
  end
end
