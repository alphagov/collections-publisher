class TagPublisher
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def publish
    Tag.transaction do
      tag.publish!
      TagBroadcaster.broadcast(tag)
    end
  end
end
