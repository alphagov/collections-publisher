class StepNavPublisher
  def self.update(step_nav)
    presenter = StepNavPresenter.new(step_nav)
    payload = presenter.render_for_publishing_api
    Services.publishing_api.put_content(step_nav.content_id, payload)
  end

  def self.discard_draft(content_id)
    Services.publishing_api.discard_draft(content_id)
  end
end
