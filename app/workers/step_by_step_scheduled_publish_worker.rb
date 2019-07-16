class StepByStepScheduledPublishWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  sidekiq_retries_exhausted do |msg, _e|
    GovukError.notify(msg['error_message'])
  end

  def perform(id)
    step_nav = nil

    StepByStepPage.transaction do
      step_nav = StepByStepPage.lock.find_by(id: id)
      StepNavPublisher.publish(step_nav)
      step_nav.mark_as_published
      generate_internal_change_note(step_nav)
    end
  end

  def generate_internal_change_note(step_nav)
    change_note = step_nav.internal_change_notes.new(
      author: "Scheduled publishing",
      description: "Published on schedule",
    )
    change_note.save!
  end
end
