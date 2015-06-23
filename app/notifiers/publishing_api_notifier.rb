require 'sidekiq'

class PublishingAPINotifier
  def self.batch_send_to_publishing_api(tag)
    if tag.child?
      parent_with_children(tag).each { |item| queue_publishing_change(item.id) }
    else
      full_hierarchy.each { |item| queue_publishing_change(item.id) }
    end
  end

  def self.send_to_publishing_api(tag)
    new(tag).send_to_publishing_api
  end

  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def send_to_publishing_api
    if tag.published?
      publishing_api.put_content_item(presenter.base_path, presenter.render_for_publishing_api)
      add_redirects
    else
      publishing_api.put_draft_content_item(presenter.base_path, presenter.render_for_publishing_api)
    end
  end

private

  def add_redirects
    redirects = tag.redirects.group_by(&:original_topic_base_path)

    redirects.each do |old_path, redirects|
      presenter = RedirectPresenter.new(redirects)
      publishing_api.put_content_item(old_path, presenter.render_for_publishing_api)
    end
  end

  def presenter
    @presenter ||= TagPresenter.presenter_for(tag)
  end

  def publishing_api
    @publishing_api ||= CollectionsPublisher.services(:publishing_api)
  end

  class QueueWorker
    include Sidekiq::Worker
    def perform(tag_id)
      t = Tag.find(tag_id)
      PublishingAPINotifier.send_to_publishing_api(t)
    end
  end

  def self.queue_publishing_change(thing)
    QueueWorker.perform_async(thing)
  end

  def self.full_hierarchy
    MainstreamBrowsePage.all
  end

  def self.parent_with_children(thing)
    thing.parent.children + [thing.parent]
  end
end
