class GroupsPresenter
  def initialize(tag)
    @tag = tag
  end

  def groups
    @tag.lists.ordered.map do |list|
      {
        name: list.name,
        contents: list.tagged_list_items.map(&:base_path)
      }
    end
  end
end
