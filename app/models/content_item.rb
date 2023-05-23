class ContentItem
  def self.find!(base_path)
    response = Services.content_store.content_item(base_path)
    new(response.to_h)
  end

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def base_path
    data["base_path"]
  end

  def mapped_specialist_topic_content_id
    data.dig("details", "mapped_specialist_topic_content_id")
  end
end
