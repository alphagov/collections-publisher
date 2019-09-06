class ReviewController < ApplicationController
  layout 'admin_layout'

  before_action :require_gds_editor_permissions!
  before_action :require_unreleased_feature_permissions!
  before_action :set_step_by_step_page

  def submit_for_2i; end

private

  def set_step_by_step_page
    @step_by_step_page = StepByStepPage.find(params[:step_by_step_page_id])
  end
end
