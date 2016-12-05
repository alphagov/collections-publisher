class ArchivedTagPresenter
  def initialize(tag)
    @tag = tag
  end

  def draft?
    @tag.draft?
  end

  def archived?
    @tag.archived?
  end

  def render_for_publishing_api
    {
      content_id: content_id,
      base_path: base_path,
      document_type: 'redirect',
      schema_name: 'redirect',
      publishing_app: 'collections-publisher',
      redirects: RedirectRoutePresenter.new(@tag).routes,
    }
  end

  def base_path
    @tag.base_path
  end

  def content_id
    @tag.content_id
  end
end
