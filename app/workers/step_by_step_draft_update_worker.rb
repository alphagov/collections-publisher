class StepByStepDraftUpdateWorker
  include Sidekiq::Worker

  def perform(step_by_step_page_id)
    @step_by_step_page_id = step_by_step_page_id

    return unless step_by_step_page

    update_navigation_rules
    update_draft
  end

  def step_by_step_page
    @step_by_step_page ||= StepByStepPage.find_by(id: @step_by_step_page_id)
  end

  def update_navigation_rules
    StepLinksForRules.update(step_by_step_page)
  end

  def update_draft
    StepNavPublisher.update(step_by_step_page)
  end
end
