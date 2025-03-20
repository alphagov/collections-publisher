class ArchivedTagPresenter
  def initialize(tag)
    @tag = tag
  end

  delegate :draft?, to: :@tag

  delegate :archived?, to: :@tag

  def render_for_publishing_api
    {
      base_path:,
      document_type: "redirect",
      schema_name: "redirect",
      publishing_app: "collections-publisher",
      redirects: RedirectRoutePresenter.new(@tag).routes,
      update_type: "minor",
    }
  end

  delegate :base_path, to: :@tag

  delegate :content_id, to: :@tag
end
