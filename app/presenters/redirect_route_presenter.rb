class RedirectRoutePresenter
  def initialize(tag)
    @tag = tag
  end

  def routes
    @tag.redirect_routes.map do |route|
      {
        path: route.from_base_path,
        destination: route.to_base_path,
        type: 'exact'
      }
    end
  end
end
