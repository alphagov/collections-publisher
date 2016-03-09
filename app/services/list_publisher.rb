class ListPublisher
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def perform
    groups = GroupsPresenter.new(tag).groups
    tag.update!(published_groups: groups, dirty: false)
    PublishingAPINotifier.notify(tag)
  end
end
