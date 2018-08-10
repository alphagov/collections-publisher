class LinkReportController < ApplicationController
  before_action :set_link_report

  def update
    unless set_link_report.nil?
      @link_report.completed = link_report_params[:completed_at]
      @link_report.save
    end
  end

private

  def link_report_params
    params.permit(:id, :completed_at)
  end

  def set_link_report
    @link_report = LinkReport.find_by(batch_id: params[:id])
  end
end
