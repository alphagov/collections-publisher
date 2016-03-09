class DependentTagPublishWorker
  include Sidekiq::Worker

  def perform(tag_id)
    tag = Tag.find(tag_id)

    tag.dependent_tags.each do |tag|
      presenter = TagPresenter.presenter_for(tag)
      ContentItemPublisher.new(presenter).send_to_publishing_api
    end

    return unless tag.can_have_children?

    if tag.is_a?(MainstreamBrowsePage)
      presenter = RootBrowsePagePresenter.new({ 'state' => tag.state })
      ContentItemPublisher.new(presenter).send_to_publishing_api
    end

    if tag.is_a?(Topic)
      presenter = RootTopicPresenter.new({ 'state' => tag.state })
      ContentItemPublisher.new(presenter).send_to_publishing_api
    end
  end
end
