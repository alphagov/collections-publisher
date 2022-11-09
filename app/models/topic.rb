class Topic < Tag
  has_many :mainstream_browse_pages, through: :reverse_tag_associations, source: :from_tag

  alias_method :subtopic?, :has_parent?

  def base_path
    "/topic/#{full_slug}"
  end

  def subroutes
    return [] unless subtopic?

    %w[/latest]
  end

  def dependent_tags
    if has_parent?
      [parent]
    else
      []
    end
  end

  def can_be_archived?
    published? && !has_active_children?
  end

  def can_be_removed?
    draft? && children.empty?
  end

  def can_have_email_subscriptions?
    level_two?
  end

  def subscriber_list_search_attributes
    { "links" => { topics: [content_id] } }
  end
end
