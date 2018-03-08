class StepByStepPagesController < ApplicationController
  before_action :require_gds_editor_permissions!
  before_action :set_step_by_step_page, only: %i[show edit update destroy]

  def index
    @step_by_step_pages = StepByStepPage.all
  end

  def new
    @step_by_step_page = StepByStepPage.new
  end

  def show; end

  def edit; end

  def create
    @step_by_step_page = StepByStepPage.new(step_by_step_page_params)

    if @step_by_step_page.save
      redirect_to @step_by_step_page, notice: 'Step by step page was successfully created.'
    else
      render :new
    end
  end

  def update
    if @step_by_step_page.update(step_by_step_page_params)
      StepNavPublisher.update(@step_by_step_page) if @step_by_step_page.steps.any?

      redirect_to step_by_step_page_path, notice: 'Step by step page was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    StepNavPublisher.discard_draft(@step_by_step_page.content_id)

    if @step_by_step_page.destroy
      redirect_to step_by_step_pages_path, notice: 'Step by step page was successfully deleted.'
    else
      render :edit
    end
  end

private

  def set_step_by_step_page
    @step_by_step_page = StepByStepPage.find(params[:id])
  end

  def step_by_step_page_params
    params.require(:step_by_step_page).permit(:title, :slug, :introduction, :description)
  end
end
