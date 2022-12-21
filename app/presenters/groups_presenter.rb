class GroupsPresenter
  def initialize(tag)
    @tag = tag
  end

  def groups
    @tag.lists.ordered.map do |list|
      {
        name: list.name,
        content_ids: list.tagged_list_items.map(&:content_id),
      }
    end
  end
end
