class StepNavPublisher
  def self.update(step_nav, publish_intent = PublishIntent.minor_update)
    presenter = StepNavPresenter.new(step_nav)
    payload = presenter.render_for_publishing_api(publish_intent)
    Services.publishing_api.put_content(step_nav.content_id, payload)
  end

  def self.discard_draft(content_id)
    Services.publishing_api.discard_draft(content_id)
  end

  def self.lookup_content_ids(base_paths)
    Services.publishing_api.lookup_content_ids(base_paths: base_paths, with_drafts: true)
  end

  def self.publish(step_nav)
    Services.publishing_api.publish(step_nav.content_id)
  end

  def self.unpublish(step_nav, redirect_url)
    Services.publishing_api.unpublish(step_nav.content_id, type: "redirect", alternative_path: redirect_url)
  end
end
