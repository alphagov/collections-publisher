class PublishingAPINotifier
  def self.send_to_publishing_api(tag)
    new(tag).send_single_tag_to_publishing_api
    tag.dependent_tags.each { |item| QueueWorker.perform_async(item.id) }
    publish_root_page(tag)
  end

  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def send_single_tag_to_publishing_api
    if tag.published?
      unless tag.archived?
        publishing_api.put_content_item(presenter.base_path, presenter.render_for_publishing_api)
      end

      add_redirects
    else
      publishing_api.put_draft_content_item(presenter.base_path, presenter.render_for_publishing_api)
    end
  end

private

  def add_redirects
    redirects = tag.redirects.group_by(&:original_tag_base_path)

    redirects.each do |old_path, redirects|
      presenter = RedirectPresenter.new(redirects)
      publishing_api.put_content_item(old_path, presenter.render_for_publishing_api)
    end
  end

  def presenter
    @presenter ||= TagPresenter.presenter_for(tag)
  end

  def publishing_api
    Services.publishing_api
  end

  def self.publish_root_page(tag)
    return unless tag.can_have_children?

    if tag.is_a?(MainstreamBrowsePage)
      RootBrowsePageWorker.perform_async
    end

    if tag.is_a?(Topic)
      RootTopicWorker.perform_async
    end
  end

  class QueueWorker
    include Sidekiq::Worker
    def perform(tag_id)
      tag = Tag.find(tag_id)
      PublishingAPINotifier.new(tag).send_single_tag_to_publishing_api
    end
  end

  class RootBrowsePageWorker
    include Sidekiq::Worker
    def perform
      Services.publishing_api.put_content_item("/browse", RootBrowsePagePresenter.new.render_for_publishing_api)
    end
  end

  class RootTopicWorker
    include Sidekiq::Worker
    def perform
      Services.publishing_api.put_content_item("/topic", RootTopicPresenter.new.render_for_publishing_api)
    end
  end
end
