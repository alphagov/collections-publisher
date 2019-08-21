class StepByStepFilter
  attr_reader :status

  def initialize(params)
    @status = params[:status]
  end

  def results
    StepByStepPage.select { |step_by_step| step_by_step.status[:name] == status }
  end
end
