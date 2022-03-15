class CopyMainstreamBrowsePageToTopic
  def self.call(*args)
    new(*args).copy
  end

  attr_reader :mainstream_browse_page

  def initialize(mainstream_browse_page)
    @mainstream_browse_page = mainstream_browse_page
  end

  def copy
    topic = Topic.new

    topic.attributes = {
      slug: "#{mainstream_browse_page.slug}-copy", # TODO: fix Validation failed: Slug has already been taken
      title: mainstream_browse_page.title,
      description: mainstream_browse_page.description,
      parent_id: mainstream_browse_page.parent_id,
      # mainstream_browse_copy: true,
    }

    TagBroadcaster.broadcast(topic) if topic.save!
  end
end
