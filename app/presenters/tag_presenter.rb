class TagPresenter
  delegate :legacy_tag_type, :base_path, to: :tag

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


  def content_id
    tag.content_id
  end

  def update_type
    'major'
  end

  def render_for_rummager
    {
      format: rummager_format,
      title: tag.title,
      description: tag.description,
      link: tag.base_path,
      slug: tag.full_slug,
    }
  end

  def render_for_publishing_api
    {
      base_path: base_path,
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
      update_type: update_type,
      details: details,
    }.merge(phase_state)
  end


  def render_links_for_publishing_api
    {
      links: links
    }
  end

  def render_for_panopticon
    {
      content_id: tag.content_id,
      description: tag.description,
      parent_id: parent.slug,
      tag_id: tag_id,
      tag_type: legacy_tag_type,
      title: tag.title,
    }
  end

  def routes
    [{ path: base_path, type: "exact" }] + subroutes
  end

private

  def phase_state
    return {} unless @tag.beta?
    { phase: "beta" }
  end

  def format
    raise "Need to subclass"
  end

  def subroutes
    @tag.subroutes.map do |suffix|
      { path: "#{base_path}#{suffix}", type: "exact" }
    end
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
    tag.published_groups
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
