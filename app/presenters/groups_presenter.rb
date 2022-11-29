class GroupsPresenter
  def initialize(tag)
    @tag = tag
  end

  def groups
    @tag.lists.ordered.map do |list|
      {
        name: list.name,
        contents: list.tagged_list_items.map(&:base_path), # should be removed once migration to content_ids is complete
        content_ids: list.tagged_list_items.map(&:content_id),
      }
    end
  end
end
