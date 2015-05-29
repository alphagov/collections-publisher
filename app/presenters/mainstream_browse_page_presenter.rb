class MainstreamBrowsePagePresenter < TagPresenter

private

  def format
    'mainstream_browse_page'
  end

  def links
    super.merge(
      "related_topics" => @tag.topics.order(:title).map(&:content_id),
    )
  end
end
