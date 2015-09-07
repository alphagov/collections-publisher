class DraftTagRemover
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def remove
    return if tag.published? || tag.parent? || tag.tagged_documents.any?

    add_gone_item
    tag.destroy!
  end

private

  def add_gone_item
    presenter = TagPresenter.presenter_for(tag)

    Services.publishing_api.put_draft_content_item(tag.base_path,
      format: 'gone',
      publishing_app: 'collections-publisher',
      update_type: 'major',
      content_id: tag.content_id,
      routes: presenter.routes
    )
  end
end
