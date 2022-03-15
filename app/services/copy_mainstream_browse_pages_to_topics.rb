class CopyMainstreamBrowsePagesToTopics
  def self.call(*args)
    new(*args).copy
  end

  attr_reader :mainstream_browse_pages

  def initialize(mainstream_browse_pages)
    @mainstream_browse_pages = mainstream_browse_pages
  end

  def copy
    new_topics = mainstream_browse_pages.map do |page|
      new_topic = create_basic_topic(page)
    rescue StandardError => e
      Rails.logger.debug "Saving topic `#{page.title}` failed with error: #{e}"
      nil
    end

    new_topics.compact.each do |topic|
      send_to_publishing_api(topic)
    rescue StandardError => e
      Rails.logger.debug "`#{topic.title}` failed with error: #{e}"
    end
  end

private

  def create_basic_topic(mainstream_browse_page)
    Topic.find_or_create_by!(
      slug: "#{mainstream_browse_page.slug}-mainstream-copy", # Unique slug constraint
    ) do |topic|
      topic.title = mainstream_browse_page.title
      topic.description = mainstream_browse_page.description
      topic.parent_id = mainstream_browse_page.parent_id
      topic.child_ordering = mainstream_browse_page.child_ordering
    end
  end

  def send_to_publishing_api(topic)
    TagPublisher.new(topic).publish
  end
end
