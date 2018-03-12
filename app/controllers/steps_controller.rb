class StepsController < ApplicationController
  def new
    @step = step_by_step_page.steps.new
  end

  def create
    step_params = params.require(:step).permit!
    @step = step_by_step_page.steps.new(step_params)

    if @step.save
      StepNavPublisher.update(step_by_step_page.reload)
      redirect_to step_by_step_page_path(step_by_step_page.id), notice: 'Step was successfully created.'
    else
      render :new
    end
  end

  def edit
    step
  end

  def update
    step_params = params.require(:step).permit!

    if step.update(step_params)
      StepNavPublisher.update(step_by_step_page.reload)
      redirect_to step_by_step_page_path(step_by_step_page.id), notice: 'Step was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    StepNavPublisher.update(step_by_step_page)
    if step.destroy
      redirect_to step_by_step_page_path(step_by_step_page.id), notice: 'Step was successfully deleted.'
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
    params.require(:step).permit(:title, :logic, :optional, :contents, :optional_heading, :optional_contents)
  end
end
