class StepByStepFilter
  attr_reader :status, :title_or_url

  def initialize(params)
    @status = params[:status]
    @title_or_url = params[:title_or_url]
  end

  def results
    return filter_by_status if status.present?

    filter_by_title_or_url if title_or_url.present?
  end

private

  def filter_by_status
    StepByStepPage.select { |step_by_step| step_by_step.status[:name] == status }
  end

  def filter_by_title_or_url
    StepByStepPage.where("title LIKE ?", "%#{title_or_url}%")
      .or(StepByStepPage.where(slug: title_or_url))
  end
end
