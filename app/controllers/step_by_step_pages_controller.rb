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

  def reorder
    @step_by_step_page = StepByStepPage.find(params[:step_by_step_page_id])

    if request.post? && params.key?(:step_order_save)
      reordered_steps = JSON.parse(params[:step_order_save])

      reordered_steps.each do |step_data|
        step = @step_by_step_page.steps.find(step_data["id"])
        step.update_attribute(:position, step_data["position"])
      end

      StepNavPublisher.update(@step_by_step_page)

      redirect_to @step_by_step_page, notice: 'Steps were successfully reordered.'
    end
  end

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
      StepNavPublisher.update(@step_by_step_page)

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

  def unpublish
    @step_by_step_page = StepByStepPage.find(params[:step_by_step_page_id])

    if request.post?
      redirect_url = params.delete("redirect_url")

      if StepByStepPage.validate_redirect(redirect_url)
        unpublish_page_in_publishing_api(@step_by_step_page, redirect_url)
      else
        redirect_to(
          step_by_step_page_unpublish_path(@step_by_step_page),
          danger: 'Redirect path is invalid. Step by step page has not been unpublished.'
        )
      end
    end
  end

private

  def unpublish_page_in_publishing_api(step_page, redirect_url)
    Services.publishing_api.unpublish(
      step_page.content_id,
      type: "redirect",
      alternative_path: redirect_url
    )

    redirect_to(
      step_by_step_pages_path,
      notice: 'Step by step page was successfully unpublished.'
    )
  rescue GdsApi::HTTPNotFound
    redirect_to(
      step_by_step_page_unpublish_path(step_page),
      alert: 'Step by step page has not been unpublished.'
    )
  end

  def set_step_by_step_page
    @step_by_step_page = StepByStepPage.find(params[:id])
  end

  def step_by_step_page_params
    params.require(:step_by_step_page).permit(:title, :slug, :introduction, :description)
  end
end
