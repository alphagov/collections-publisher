class ReviewController < ApplicationController
  layout 'admin_layout'

  before_action :require_gds_editor_permissions!
  before_action :require_unreleased_feature_permissions!
  before_action :set_step_by_step_page

  def submit_for_2i
    if request.post?
      if @step_by_step_page.update(
        review_requester_id: current_user.uid,
        status: "submitted_for_2i"
      )
        @step_by_step_page.internal_change_notes.create(
          author: current_user.name,
          description: "Submitted for 2i by #{current_user.name}"
        )

        redirect_to step_by_step_page_path(@step_by_step_page.id), notice: 'Step by step page was successfully submitted for 2i.'
      else
        render :submit_for_2i
      end
    end
  end

private

  def set_step_by_step_page
    @step_by_step_page = StepByStepPage.find(params[:step_by_step_page_id])
  end
end
