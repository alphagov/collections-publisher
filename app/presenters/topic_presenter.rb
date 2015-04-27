class TopicPresenter < TagPresenter

private
  def format
    'topic'
  end

  def routes
    return super unless @tag.has_parent?

    super + [
      {path: "#{base_path}/latest", type: "exact"},
      {path: "#{base_path}/email-signup", type: "exact"},
      {path: "#{base_path}/email-signups", type: "exact"},
    ]
  end

  def details
    super.merge({
      :groups => categorized_groups,
    })
  end

  def categorized_groups
    @tag.lists.ordered.map do |list|
      {
        name: list.name,
        contents: list.tagged_list_items.map(&:api_url)
      }
    end
  end

  def tag_type
    'specialist_sector'
  end

end
