class LinkReportController < ApplicationController
  before_action :set_link_report
  skip_before_action :verify_authenticity_token

  def update
    unless set_link_report.nil?
      @link_report.completed = params[:completed_at]
      @link_report.save
    end
  end

private

  def set_link_report
    @link_report = LinkReport.find_by(batch_id: params[:id])
  end
end
