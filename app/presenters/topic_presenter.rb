class TopicPresenter < TagPresenter

private

  def rummager_format
    'specialist_sector'
  end

  def format
    'topic'
  end

  def routes
    return super unless @tag.has_parent?

    super + [
      {path: "#{base_path}/latest", type: "exact"},
      {path: "#{base_path}/email-signup", type: "exact"},
    ]
  end

  def details
    super.merge({
      :beta => @tag.beta,
    })
  end

  def links
    if @tag.has_parent?
      super.merge({
        "parent" => [@tag.parent.content_id],
      })
    else
      super.merge({
        "children" => @tag.children.order(:title).map(&:content_id),
      })
    end
  end
end
