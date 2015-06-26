class RummagerNotifier
  attr_reader :topic

  def initialize(topic)
    @topic = topic
  end

  def notify
    return if topic.draft?

    # Will add it to mainstream index with type 'edition'.
    CollectionsPublisher.services(:rummager).add_document(
      'edition',
      topic.base_path,
      payload
    )
  end

  private

  def payload
    {
      format: 'specialist_sector',
      title: topic.title,
      description: topic.description,
      link: topic.base_path,
    }
  end
end
