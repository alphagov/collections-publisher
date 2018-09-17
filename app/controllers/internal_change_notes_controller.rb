class InternalChangeNotesController < ApplicationController
  def create
    InternalChangeNote.create(required_fields.merge(other_fields))
    redirect_to step_by_step_page_internal_change_notes_path, notice: 'Change note was successfully added.'
  end

private

  def step_by_step_page
    StepByStepPage.find(params[:step_by_step_page_id])
  end

  def required_fields
    params.require(:internal_change_note).permit(:description)
  end

  def other_fields
    {
      step_by_step_page_id: step_by_step_page.id,
      created_at: Time.now,
      author: current_user.name
    }
  end
end
