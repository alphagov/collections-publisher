class StepNavPublisher
  def self.update(step_by_step_page, publish_intent = PublishIntent.minor_update)
    step_by_step_page.mark_draft_updated
    presenter = StepNavPresenter.new(step_by_step_page)
    payload = presenter.render_for_publishing_api(publish_intent)
    Services.publishing_api.put_content(step_by_step_page.content_id, payload)
  end

  def self.discard_draft(step_by_step_page)
    Services.publishing_api.discard_draft(step_by_step_page.content_id)
  end

  def self.lookup_content_ids(base_paths)
    Services.publishing_api.lookup_content_ids(base_paths: base_paths, with_drafts: true)
  end

  def self.publish(step_by_step_page)
    Services.publishing_api.publish(step_by_step_page.content_id)
  end

  def self.unpublish(step_by_step_page, redirect_url)
    Services.publishing_api.unpublish(step_by_step_page.content_id, type: "redirect", alternative_path: redirect_url)
  end

  def self.schedule_for_publishing(step_by_step_page)
    StepByStepScheduledPublishWorker.perform_at(step_by_step_page.scheduled_at, step_by_step_page.id)
  end
end
