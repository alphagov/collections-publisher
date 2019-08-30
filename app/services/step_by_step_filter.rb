class StepByStepFilter
  attr_reader :status, :title_or_url, :order_by

  def initialize(params = {})
    @status = params[:status]
    @title_or_url = params[:title_or_url]
    @order_by = params[:order_by].to_sym if params[:order_by]
  end

  def results
    return filtered_results.sort_by { |result| result[order_by] } if order_by

    filtered_results.sort_by(&:title)
  end

private

  def filtered_results
    if status.present? && title_or_url.present?
      filter_by_status & filter_by_title_or_url
    elsif status.present?
      filter_by_status
    elsif title_or_url.present?
      filter_by_title_or_url
    else
      StepByStepPage.by_title
    end
  end

  def filter_by_status
    StepByStepPage.select { |step_by_step| step_by_step.status == status }
  end

  def filter_by_title_or_url
    StepByStepPage.where("title LIKE ?", "%#{title_or_url}%")
      .or(StepByStepPage.where(slug: slug_from_title_or_url))
  end

  def slug_from_title_or_url
    title_or_url.split('/').last
  end
end
