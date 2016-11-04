class MainstreamBrowsePage < Tag
  has_many :topics, through: :tag_associations, source: :to_tag

  validate :parents_cannot_have_topics_associated

  accepts_nested_attributes_for :children

  def base_path
    "/browse/#{full_slug}"
  end

  def dependent_tags
    if child?
      parent.children - [self] + [parent]
    else
      MainstreamBrowsePage.all - [self]
    end
  end

  def subroutes
    %w[.json]
  end

  def top_level_mainstream_browse_page?
    !child?
  end

private

  def parents_cannot_have_topics_associated
    if !parent.present? && topics.any?
      errors.add(:topics, "top-level mainstream browse pages cannot have topics assigned to them")
    end
  end
end
