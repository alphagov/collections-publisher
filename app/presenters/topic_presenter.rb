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
    ]
  end

  def details
    super.merge({
      :beta => @tag.beta,
    })
  end
end
