class MainstreamBrowsePagePresenter < TagPresenter
private

  GDS_CONTENT_ID = "af07d5a5-df63-4ddc-9383-6a666845ebe9".freeze

  def format
    "mainstream_browse_page"
  end

  def links
    super.merge(
      "related_topics" => @tag.topics.order(:title).map(&:content_id),
      "active_top_level_browse_page" => active_top_level_browse_page_id,
      "top_level_browse_pages" => @tag.class.sorted_level_one.map(&:content_id),
      "second_level_browse_pages" => second_level_browse_pages,
      "primary_publishing_organisation" => [GDS_CONTENT_ID],
    )
  end

  def details
    super.merge(
      "second_level_ordering" => second_level_ordering,
      "ordered_second_level_browse_pages" => second_level_browse_pages,
    )
  end

  def active_top_level_browse_page_id
    if @tag.has_parent?
      [@tag.parent.content_id]
    else
      [@tag.content_id]
    end
  end

  def second_level_browse_pages
    if @tag.level_two?
      @tag.parent.sorted_children.map(&:content_id)
    else
      @tag.sorted_children.map(&:content_id)
    end
  end

  def second_level_ordering
    if @tag.level_two?
      @tag.parent.child_ordering
    else
      @tag.child_ordering
    end
  end
end
