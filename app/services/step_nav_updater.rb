class StepNavUpdater
  def self.call(step_nav)
    presenter = StepNavPresenter.new(step_nav)
    payload = presenter.render_for_publishing_api
    Services.publishing_api.put_content(step_nav.content_id, payload)
  end
end
