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

      tag_documents_to_topics(page.tagged_documents, new_topic) if page.tagged_documents.any?

      new_topic
    rescue StandardError => e
      Rails.logger.debug "Saving topic `#{page.title}` failed with error: #{e}"
      nil
    end

    new_topics.compact.each do |topic|
      update_parent_to_new_topic(topic) if topic.has_parent?
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
      topic.mainstream_browse_origin = mainstream_browse_page.content_id
    end
  end

  def tag_documents_to_topics(documents_to_tag, new_topic)
    documents_to_tag.each do |document|
      links_payload = Services.publishing_api.get_links(document.content_id)["links"]

      if links_payload.key?("topics")
        links_payload["topics"] << new_topic.content_id
      else
        links_payload.merge!("topics": [new_topic.content_id])
      end

      Services.publishing_api.patch_links(
        document.content_id,
        links: links_payload,
        bulk_publishing: true,
      )
    end
  end

  def update_parent_to_new_topic(topic)
    parent_topic = Topic.find_by(title: topic.parent&.title)

    topic.attributes = {
      parent_id: parent_topic.try(:id),
    }

    topic.save!
  end

  def send_to_publishing_api(topic)
    TagPublisher.new(topic).publish
  end
end
