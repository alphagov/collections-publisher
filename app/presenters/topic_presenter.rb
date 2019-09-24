class TopicPresenter < TagPresenter
private # rubocop:disable Layout/IndentationWidth

  GDS_CONTENT_ID = "af07d5a5-df63-4ddc-9383-6a666845ebe9".freeze

  def format
    "topic"
  end

  def links
    super.merge(
      "primary_publishing_organisation" => [GDS_CONTENT_ID],
    )
  end
end
