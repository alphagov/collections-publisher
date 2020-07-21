class InternalChangeNotesController < ApplicationController
  include PublishingApiHelper

  def create
    InternalChangeNote.create!(required_fields.merge(other_fields))
    redirect_to step_by_step_page_internal_change_notes_path, notice: "Change note was successfully added."
  end

private

  def step_by_step_page
    StepByStepPage.find(params[:step_by_step_page_id])
  end

  def required_fields
    params.require(:internal_change_note).permit(:description)
  end

  def other_fields
    fields = {
      step_by_step_page_id: step_by_step_page.id,
      headline: "Internal note",
      author: current_user.name,
    }

    fields[:edition_number] = latest_edition_number(step_by_step_page.content_id) if save_edition_number?

    fields
  end

  def save_edition_number?
    step_by_step_page.has_been_published? && !step_by_step_page.has_draft?
  end
end
