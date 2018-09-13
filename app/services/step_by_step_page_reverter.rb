class StepByStepPageReverter
  attr_reader :step_by_step_page, :payload_from_publishing_api

  def initialize(step_by_step_page, payload_from_publishing_api)
    @step_by_step_page = step_by_step_page
    @payload_from_publishing_api = payload_from_publishing_api.with_indifferent_access
  end

  def repopulate_from_publishing_api
    step_by_step_page.title = payload_from_publishing_api[:title]

    step_by_step_page.save!
  end
end
