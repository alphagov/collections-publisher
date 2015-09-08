class DraftTagRemover
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def remove
    return if tag.published? || tag.parent? || tag.tagged_documents.any?

    remove_tag_from_panopticon
    add_gone_item
    tag.destroy!
  end

private

  def add_gone_item
    Services.publishing_api.put_draft_content_item(tag.base_path,
      format: 'gone',
      publishing_app: 'collections-publisher',
      update_type: 'major',
      content_id: tag.content_id,
      routes: presenter.routes
    )
  end

  def remove_tag_from_panopticon
    tag_hash = presenter.render_for_panopticon
    Services.panopticon.delete_tag!(tag_hash[:tag_type], tag_hash[:tag_id])
  end

  def presenter
    @presenter ||= TagPresenter.presenter_for(tag)
  end
end
