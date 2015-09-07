class MainstreamBrowsePagePresenter < TagPresenter

private

  def rummager_format
    'mainstream_browse_page'
  end

  def format
    'mainstream_browse_page'
  end

  def links
    super.merge(
      "related_topics" => @tag.topics.order(:title).map(&:content_id),
      "active_top_level_browse_page" => active_top_level_browse_page_id,
      "top_level_browse_pages" => @tag.class.sorted_parents.map(&:content_id),
      "second_level_browse_pages" => second_level_browse_pages,
    )
  end

  def details
    super.merge(
      "second_level_ordering" => second_level_ordering
    )
  end

private

  def active_top_level_browse_page_id
    if @tag.has_parent?
      [@tag.parent.content_id]
    else
      [@tag.content_id]
    end
  end

  def second_level_browse_pages
    if @tag.child?
      @tag.parent.sorted_children.map(&:content_id)
    else
      @tag.sorted_children.map(&:content_id)
    end
  end

  def second_level_ordering
    if @tag.child?
      @tag.parent.child_ordering
    else
      @tag.child_ordering
    end
  end

end
