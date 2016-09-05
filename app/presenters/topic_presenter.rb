class TopicPresenter < TagPresenter
private

  def rummager_format
    'specialist_sector'
  end

  def format
    'topic'
  end

  def details
    super.merge({
      :beta => @tag.beta,
    })
  end
end
