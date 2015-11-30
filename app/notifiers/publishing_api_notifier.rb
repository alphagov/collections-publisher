class PublishingAPINotifier
  def self.send_to_publishing_api(tag)
    new(tag).write_content
    tag.dependent_tags.each { |item| QueueWorker.perform_async(item.id) }
    publish_root_page(tag)
  end

  def self.publish(tag)
    new(tag).write_content
    tag.dependent_tags.each { |item| 
      QueueWorker.perform_async(item.id) }
    publish_root_page(tag)
  end

  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def write_content
    PublishingApiContentWriter.write(presenter)
  end

private
  
  def presenter
    @presenter ||= TagPresenter.presenter_for(tag)
  end

  def publishing_api
    Services.publishing_api
  end

  def self.publish_root_page(tag)
    return unless tag.can_have_children?
    to_be_published = tag.state == "published"

    if tag.is_a?(MainstreamBrowsePage)
      RootBrowsePageWorker.perform_async(to_be_published)
    end

    if tag.is_a?(Topic)
      RootTopicWorker.perform_async(to_be_published)
    end
  end

  class PublishingApiContentWriter
    def self.write(presenter)
      publishing_api = Services.publishing_api
      publishing_api.put_content(presenter.content_id, presenter.render_for_publishing_api)
      publishing_api.publish(presenter.content_id, presenter.update_type) unless presenter.draft?
      publishing_api.put_links(presenter.content_id, presenter.render_links_for_publishing_api) unless presenter.archived?
    end
  end

  class QueueWorker
    include Sidekiq::Worker
    def perform(tag_id)
      tag = Tag.find(tag_id)
      PublishingAPINotifier.new(tag).write_content
    end
  end

  class RootBrowsePageWorker
    include Sidekiq::Worker
    def perform(to_be_published)
      presenter = RootBrowsePagePresenter.new(to_be_published)
      PublishingApiContentWriter.write(presenter)
    end
  end

  class RootTopicWorker
    include Sidekiq::Worker
    def perform(to_be_published)
      presenter = RootTopicPresenter.new(to_be_published)
      PublishingApiContentWriter.write(presenter)
    end
  end
end
