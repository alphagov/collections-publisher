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
    if tag.is_a?(MainstreamBrowsePage)
      RootBrowsePageWorker.perform_async('state' => tag.state)
    end

    if tag.is_a?(Topic)
      RootTopicWorker.perform_async('state' => tag.state)
    end
  end

  class PublishingApiContentWriter
    # Setting the update type to minor means we won't send email alerts for
    # changes to a topic title or description.
    UPDATE_TYPE = 'minor'

    def self.write(presenter)
      publishing_api = Services.publishing_api
      publishing_api.put_content(presenter.content_id, presenter.render_for_publishing_api)
      publishing_api.publish(presenter.content_id, UPDATE_TYPE) unless presenter.draft?
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
    def perform(options)
      presenter = RootBrowsePagePresenter.new(options)
      PublishingApiContentWriter.write(presenter)
    end
  end

  class RootTopicWorker
    include Sidekiq::Worker
    def perform(options)
      presenter = RootTopicPresenter.new(options)
      PublishingApiContentWriter.write(presenter)
    end
  end
end
