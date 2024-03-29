class MainstreamBrowsePage < Tag
  validate :children_index_present, on: :update

  accepts_nested_attributes_for :children

  def base_path
    "/browse/#{full_slug}"
  end

  def dependent_tags
    if level_two?
      parent.children - [self] + [parent]
    else
      MainstreamBrowsePage.all - [self]
    end
  end

  def subroutes
    %w[.json]
  end

  def can_be_archived?
    level_two? && published?
  end

  def can_be_removed?
    level_two? && draft?
  end

  def can_have_email_subscriptions?
    false
  end

private

  def children_index_present
    return if children.blank?

    sorted_children = sorted_children_that_are_not_archived
    children_with_no_index = sorted_children.select { |child| child.index.nil? }

    children_with_no_index.each do |child|
      errors.add("children_attributes_#{sorted_children.find_index(child)}_index".to_sym, message: "Enter an index for #{child.title}")
    end
  end
end
