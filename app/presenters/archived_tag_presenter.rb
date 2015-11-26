class ArchivedTagPresenter
  def initialize(tag)
    @tag = tag
  end

  def render_for_publishing_api
    {
      content_id: @tag.content_id,
      base_path: @tag.base_path,
      format: 'redirect',
      publishing_app: 'collections-publisher',
      update_type: 'major',
      redirects: RedirectRoutePresenter.new(@tag).routes
    }
  end

  def base_path
    @tag.base_path
  end
end
