class Topic < Tag
  has_many :mainstream_browse_pages, through: :reverse_tag_associations, source: :from_tag

  alias_method :subtopic?, :has_parent?

  attr_accessor :mainstream_browse_origin

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
end
