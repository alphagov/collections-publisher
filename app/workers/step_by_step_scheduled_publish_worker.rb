class StepByStepScheduledPublishWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  sidekiq_retries_exhausted do |msg, _e|
    GovukError.notify(msg['error_message'])
  end

  def perform(id)
    step_nav = StepByStepPage.find_by(id: id)

    if publish_now?(step_nav)
      step_nav.with_lock do
        StepNavPublisher.publish(step_nav)
        step_nav.mark_as_published
        generate_internal_change_note(step_nav)
      end
    end
  end

  def generate_internal_change_note(step_nav)
    change_note = step_nav.internal_change_notes.new(
      author: "Scheduled publishing",
      description: "Published on schedule",
    )
    change_note.save!
  end

private

  def publish_now?(step_nav)
    step_nav.scheduled_for_publishing? && !scheduled_in_future?(step_nav)
  end

  def scheduled_in_future?(step_nav)
    step_nav.scheduled_at > Time.zone.now
  end
end
