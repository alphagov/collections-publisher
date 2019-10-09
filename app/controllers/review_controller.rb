class ReviewController < ApplicationController
  layout "admin_layout"

  before_action :set_step_by_step_page
  before_action :require_gds_editor_permissions!
  before_action :require_2i_reviewer_permissions!, only: %i(
    approve_2i_review
    claim_2i_review
    request_change_2i_review
    show_approve_2i_review_form
    show_request_change_2i_review_form
  )
  before_action :require_user_to_be_the_2i_reviewer!, only: %i(
    approve_2i_review
    request_change_2i_review
    show_approve_2i_review_form
    show_request_change_2i_review_form
  )

  def show_approve_2i_review_form
    render :submit_2i_verdict, locals: { approved: true }
  end

  def approve_2i_review
    status = "approved_2i"

    if @step_by_step_page.update(
      review_requester_id: nil,
      reviewer_id: nil,
      status: status,
    )
      generate_change_note("2i approved", params[:additional_comment])

      redirect_to step_by_step_page_path(@step_by_step_page.id), notice: "Step by step page was successfully 2i approved. Please let the author know. This app has not sent any notifications."
    else
      render :submit_2i_verdict, locals: { approved: true }, status: :unprocessable_entity
    end
  end

  def claim_2i_review
    status = "in_review"

    if @step_by_step_page.update(
      reviewer_id: current_user.uid,
      status: status,
    )
      generate_change_note("Claimed for review")

      redirect_to step_by_step_page_path(@step_by_step_page.id), notice: "Step by step page was successfully claimed for review."
    end
  end

  def show_request_change_2i_review_form
    render :submit_2i_verdict, locals: { approved: false }
  end

  def request_change_2i_review
    status = "draft"

    if @step_by_step_page.update(
      reviewer_id: nil,
      review_requester_id: nil,
      status: status,
    )
      generate_change_note("2i changes requested", params[:requested_change])

      redirect_to step_by_step_page_path(@step_by_step_page.id), notice: "Changes to the step by step page were requested. Please let the author know. This app has not sent any notifications."
    else
      render :submit_2i_verdict, locals: { approved: false }, status: :unprocessable_entity
    end
  end

  def submit_for_2i
    if request.post?
      status = "submitted_for_2i"

      if @step_by_step_page.update(
        review_requester_id: current_user.uid,
        status: status,
      )
        generate_change_note(I18n.t!("step_by_step_page.statuses.#{status}"), params[:additional_comments])

        redirect_to step_by_step_page_path(@step_by_step_page.id), notice: "Step by step page was successfully submitted for 2i review."
      else
        render :submit_for_2i
      end
    end
  end

  def revert_to_draft
    status = "draft"

    if @step_by_step_page.update(
      reviewer_id: nil,
      review_requester_id: nil,
      status: status,
    )
      generate_change_note("Reverted to draft")

      redirect_to step_by_step_page_path(@step_by_step_page.id), notice: "Step by step page was successfully reverted to draft."
    end
  end

private

  def generate_change_note(headline, change_note = nil)
    @step_by_step_page.internal_change_notes.create(
      author: current_user.name,
      headline: headline,
      description: change_note,
    )
  end

  def set_step_by_step_page
    @step_by_step_page = StepByStepPage.find(params[:step_by_step_page_id])
  end

  def require_user_to_be_the_2i_reviewer!
    render "shared/forbidden", status: :forbidden unless current_user.uid == @step_by_step_page.reviewer_id
  end
end
