class ArchivedTagPresenter

  delegate :draft?, :archived?, to: :tag

  attr_reader :tag


  def initialize(tag)
    @tag = tag
  end

  def render_for_publishing_api
    {
      content_id: content_id,
      base_path: base_path,
      format: 'redirect',
      publishing_app: 'collections-publisher',
      update_type: update_type,
      redirects: RedirectRoutePresenter.new(@tag).routes,
    }
  end

  def base_path
    @tag.base_path
  end

  def content_id
    @tag.content_id
  end

  def update_type
    'major'
  end
 
end
