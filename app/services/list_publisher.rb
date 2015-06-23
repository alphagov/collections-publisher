class ListPublisher
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def perform
    groups = TopicPresenter.new(tag).build_groups
    tag.update!(published_groups: groups, dirty: false)
    PublishingAPINotifier.send_to_publishing_api(tag)
  end
end
