class PublishingAPINotifier
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
end
