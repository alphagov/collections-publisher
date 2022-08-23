class DraftTagRemover
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def remove
    raise "Can't delete this tag" unless tag.can_be_removed?

    Tag.transaction do
      add_gone_item
      tag.destroy!
    end
  end

private

  def add_gone_item
    Services.publishing_api.put_content(tag.content_id, render_gone_item)
  end

  def render_gone_item
    {
      base_path: tag.base_path,
      document_type: "gone",
      schema_name: "gone",
      publishing_app: "collections-publisher",
      content_id: tag.content_id,
      routes: presenter.routes,
    }
  end

  def presenter
    @presenter ||= TagPresenter.presenter_for(tag)
  end
end
