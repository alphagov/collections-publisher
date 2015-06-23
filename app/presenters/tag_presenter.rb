class TagPresenter
  delegate :legacy_tag_type, to: :tag

  def self.presenter_for(tag)
    case tag
    when MainstreamBrowsePage
      MainstreamBrowsePagePresenter.new(tag)
    when Topic
      TopicPresenter.new(tag)
    else
      raise ArgumentError, "Unexpected tag type #{tag.class}"
    end
  end

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
      locale: 'en',
      need_ids: [],
      public_updated_at: @tag.updated_at.iso8601,
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
      tag_type: legacy_tag_type,
      parent_id: parent.slug,
    }
  end

  def build_groups
    @tag.lists.ordered.map do |list|
      {
        name: list.name,
        contents: list.tagged_list_items.map(&:api_url)
      }
    end
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
    {
      :groups => categorized_groups,
    }
  end

  # Groups aren't calculated each time we publish the item, we use a rendered
  # hash from the tags instead. This allows us to independently update the
  # item, without having to publish these groups.
  def categorized_groups
    tag.published_groups || build_groups
  end

  # potentially extended in subclasses
  def links
    {}
  end

  attr_reader :tag

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
