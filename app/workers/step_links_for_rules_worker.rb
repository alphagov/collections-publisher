class StepLinksForRulesWorker
  include Sidekiq::Worker

  def perform(step_id)
    step = Step.find_by(id: step_id)
    return unless step

    StepLinksForRules.new(step: step).call
  end
end
