class TagPublisher
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def publish
    Tag.transaction do
      tag.publish!
      PanopticonNotifier.publish_tag(TagPresenter.presenter_for(tag))
      PublishingAPINotifier.send_to_publishing_api(tag)
      RummagerNotifier.new(tag).notify
    end
  end
end
