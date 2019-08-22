class StepByStepFilter
  attr_reader :status, :title_or_url

  def initialize(params)
    @status = params[:status]
    @title_or_url = params[:title_or_url]
  end

  def results
    if status.present? && title_or_url.present?
      filter_by_status & filter_by_title_or_url
    elsif status.present?
      filter_by_status
    elsif title_or_url.present?
      filter_by_title_or_url
    else
      []
    end
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
