class StepByStepUpdater
  def self.call(step_by_step, current_user)
    step_by_step.mark_draft_updated unless %w[submitted_for_2i in_review approved_2i].include?(step_by_step.status)
    StepByStepDraftUpdateJob.perform_async(step_by_step.id, current_user.name)
  end
end
