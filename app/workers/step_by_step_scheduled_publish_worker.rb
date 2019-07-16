class StepByStepScheduledPublishWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(id)
    step_nav = nil

    StepByStepPage.transaction do
      step_nav = StepByStepPage.lock.find_by(id: id)
      StepNavPublisher.publish(step_nav)
      step_nav.mark_as_published
    end
  end
end
