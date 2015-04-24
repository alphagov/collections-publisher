class TagPresenter
  def initialize(tag)
    @tag = tag
  end

  def base_path
    @tag.base_path
  end

  def render_for_publishing_api
    {
      content_id: @tag.content_id,
      format: format,
      title: @tag.title,
      description: @tag.description,
      need_ids: [],
      public_updated_at: @tag.updated_at,
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      routes: routes,
      redirects: [],
      update_type: "major",
      details: details,
      links: links,
    }
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

  def format
    raise "Need to subclass"
  end

  # potentially extended in subclasses
  def routes
    [ {path: base_path, type: "exact"} ]
  end

  # potentially extended in subclasses
  def details
    {}
  end

  # potentially extended in subclasses
  def links
    {}
  end

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
