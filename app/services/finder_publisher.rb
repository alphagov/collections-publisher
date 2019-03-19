class FinderPublisher
  attr_reader :content_id, :content_item

  def initialize(content_item)
    @content_id = content_item.delete("content_id")
    @content_item = content_item
  end

  def self.call(content_item)
    new(content_item).call
  end

  def call
    send_to_publishing_api
  end

  def unpublish(options = {})
    Services.publishing_api.unpublish(content_id, options)
  end

private

  def send_to_publishing_api
    Services.publishing_api.put_content(
      content_id,
      content_item
    )
    Services.publishing_api.publish(content_id)
  end
end
