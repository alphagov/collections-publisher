class StepByStepDraftUpdateWorker
  include Sidekiq::Worker

  def perform(step_by_step_page_id, name_of_current_user = "")
    @step_by_step_page_id = step_by_step_page_id
    @current_user = name_of_current_user
    return unless step_by_step_page
    update_assigned_to
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

  def update_assigned_to
    unless step_by_step_page.has_draft?
      step_by_step_page.assigned_to = @current_user
      step_by_step_page.save
    end
  end
end
