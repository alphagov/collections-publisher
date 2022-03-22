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
      create_basic_topic(page)
    rescue StandardError => e
      Rails.logger.debug "Saving topic `#{page.title}` failed with error: #{e}"
      nil
    end

    new_topics.compact.each do |topic|
      update_assossiations_to_topics(topic)
      send_to_publishing_api(topic)
    rescue StandardError => e
      Rails.logger.debug "`#{topic.title}` failed with error: #{e}"
    end
  end

private

  def create_basic_topic(mainstream_browse_page)
    topic = Topic.new

    topic.attributes = {
      slug: "#{mainstream_browse_page.slug}-mbp-copy", # TODO: fix Validation failed: Slug has already been taken
      title: mainstream_browse_page.title,
      description: mainstream_browse_page.description,
      parent_id: mainstream_browse_page.parent_id,
      # mainstream_browse_copy: true, #TODO: Depends on https://github.com/alphagov/govuk-content-schemas/pull/1087
    }

    topic if topic.save!
  end

  def update_assossiations_to_topics(topic)
    parent_topic = Topic.find_by(title: topic.parent&.title)

    topic.attributes = {
      parent_id: parent_topic.try(:id),
    }

    topic.save!
  end

  def send_to_publishing_api(topic)
    TagBroadcaster.broadcast(topic)
  end
end
