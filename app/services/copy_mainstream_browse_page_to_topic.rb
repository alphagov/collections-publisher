class CopyMainstreamBrowsePageToTopic
  def self.call(*args)
    new(*args).copy
  end

  attr_reader :mainstream_browse_pages

  def initialize(mainstream_browse_pages)
    @mainstream_browse_pages = mainstream_browse_pages
  end

  def copy
    new_topics = mainstream_browse_pages.map do |page|
      save_as_basic_topic(page)
    end

    new_topics.each do |topic|
      update_assossiations_to_topics(topic)
    end
  end

  private

  def save_as_basic_topic(mainstream_browse_page)
    topic = Topic.new

    topic.attributes = {
      slug: "#{mainstream_browse_page.slug}-copy", # TODO: fix Validation failed: Slug has already been taken
      title: mainstream_browse_page.title,
      description: mainstream_browse_page.description,
      # parent has to be a Topic
      parent_id: mainstream_browse_page.parent_id,
      # example https://www.gov.uk/api/content/topic/schools-colleges-childrens-services
      # https://www.gov.uk/api/content/topic/schools-colleges-childrens-services/special-educational-needs-disabilities
      # children need to be topics, children also reference parents
      # in MBP no concept of children, association with "mainstream_browse_pages"
      children: mainstream_browse_page.children,
      # mainstream_browse_copy: true,
    }

    TagBroadcaster.broadcast(topic) if topic.save!

    topic
  end

  def update_assossiations_to_topics(topic)

  end
end
