class RedirectPresenter
  attr_reader :redirects

  def initialize(redirects)
    @redirects = redirects
  end

  def render_for_publishing_api
    {
      format: 'redirect',
      publishing_app: 'collections-publisher',
      update_type: 'major',
      redirects: redirect_routes,
    }
  end

private

  def redirect_routes
    redirects.map do |redirect|
      {
        path: redirect.from_base_path,
        destination: redirect.to_base_path,
        type: 'exact',
      }
    end
  end
end
