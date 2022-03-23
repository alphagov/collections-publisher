class StepsController < ApplicationController
  before_action :require_gds_editor_permissions!

  def new
    @step = step_by_step_page.steps.new
  end

  def create
    @step = step_by_step_page.steps.new(step_params)

    if @step.save
      StepByStepUpdater.call(step_by_step_page, current_user)

      redirect_to step_by_step_page_path(step_by_step_page.id), notice: "Step was successfully created."
    else
      render :new
    end
  end

  def edit
    step
  end

  def update
    if step.update(step_params)
      StepByStepUpdater.call(step_by_step_page, current_user)
      redirect_to edit_step_by_step_page_step_path(step_by_step_page.id), notice: "Step was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    if step.destroy
      StepByStepUpdater.call(step_by_step_page, current_user)

      redirect_to step_by_step_page_path(step_by_step_page.id), notice: "Step was successfully deleted."
    else
      redirect_to step_by_step_page_path
    end
  end

private

  def step_by_step_page
    @step_by_step_page ||= StepByStepPage.find(params[:step_by_step_page_id])
  end

  def step
    @step ||= step_by_step_page.steps.find(params[:id])
  end

  def step_params
    params.require(:step).permit(:title, :logic, :contents)
  end
end
