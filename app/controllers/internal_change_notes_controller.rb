class InternalChangeNotesController < ApplicationController
  def create
    InternalChangeNote.create(internal_change_note_params.merge(step_by_step_page_id: step_by_step_page.id, created_at: Time.now, author: current_user.name))
    redirect_to step_by_step_page_internal_change_notes_path, notice: 'Change note was successfully added.'
  end

private

  def step_by_step_page
    StepByStepPage.find(params[:step_by_step_page_id])
  end

  def internal_change_note_params
    params.require(:internal_change_note).permit(:description)
  end
end
