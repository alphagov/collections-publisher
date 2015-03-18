class TagPresenter
  def initialize(tag)
    @tag = tag
  end

  def render_for_panopticon
    {
      tag_id: tag_id,
      title: tag.title,
      description: tag.description,
      tag_type: tag_type,
      parent_id: parent.slug,
    }
  end

private

  attr_reader :tag

  def tag_type
    nil
  end

  def parent
    tag.parent || NullParent.new
  end

  def tag_id
    parent.present? ? "#{parent.slug}/#{tag.slug}" : tag.slug
  end

  class NullParent
    def present?
      false
    end

    def slug
      nil
    end
  end
end
