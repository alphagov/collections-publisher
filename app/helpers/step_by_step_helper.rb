module StepByStepHelper
  def update_downstream
    StepByStepDraftUpdateWorker.perform_async(@step_by_step_page.id, current_user.name)
  end
end
