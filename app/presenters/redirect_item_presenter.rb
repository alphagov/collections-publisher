class RedirectItemPresenter
  attr_reader :item

  def initialize(item)
    @item = item
  end

  delegate :content_id, to: :item

  def base_path
    item.from_base_path
  end

  def redirect_routes
    [item]
  end

  def draft?
    false
  end

  def archived?
    true
  end

  def render_for_publishing_api
    {
      base_path:,
      document_type: "redirect",
      schema_name: "redirect",
      publishing_app: "collections-publisher",
      redirects: RedirectRoutePresenter.new(self).routes,
      update_type: "minor",
    }
  end
end
