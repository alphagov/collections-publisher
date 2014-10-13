class TagPresenter
  def initialize(tag)
    @tag = tag
  end

  def render_for_panopticon
    {
      tag_id: tag_id,
      title: tag.title,
      description: tag.description,
      tag_type: tag_type
    }
  end

private

  attr_reader :tag

  def tag_type
    nil
  end

  def tag_id
    tag.parent_id.present? ? "#{tag.parent_id}/#{tag.slug}" : tag.slug
  end
end
