class PublishingAPINotifier
  def self.send_to_publishing_api(tag)
    new(tag).write_content
    tag.dependent_tags.each { |item| QueueWorker.perform_async(item.id) }
    publish_root_page(tag)
  end

  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def write_content
    ContentItemPublisher.new(presenter).send_to_publishing_api
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

    if tag.is_a?(MainstreamBrowsePage)
      RootBrowsePageWorker.perform_async('state' => tag.state)
    end

    if tag.is_a?(Topic)
      RootTopicWorker.perform_async('state' => tag.state)
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
    def perform(options)
      presenter = RootBrowsePagePresenter.new(options)
      ContentItemPublisher.new(presenter).send_to_publishing_api
    end
  end

  class RootTopicWorker
    include Sidekiq::Worker
    def perform(options)
      presenter = RootTopicPresenter.new(options)
      ContentItemPublisher.new(presenter).send_to_publishing_api
    end
  end
end
