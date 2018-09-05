class StepByStepPagesController < ApplicationController
  before_action :require_gds_editor_permissions!
  before_action :set_step_by_step_page, only: %i[show edit update destroy]

  def index
    @step_by_step_pages = StepByStepPage.by_title
  end

  def new
    @step_by_step_page = StepByStepPage.new
  end

  def show; end

  def reorder
    set_current_page_as_step_by_step
    if request.post? && params.key?(:step_order_save)
      reordered_steps = JSON.parse(params[:step_order_save])
      reordered_steps.each do |step_data|
        step = @step_by_step_page.steps.find(step_data["id"])
        step.update_attribute(:position, step_data["position"])
      end
      update_downstream
      redirect_to @step_by_step_page, notice: 'Steps were successfully reordered.'
    end
  end

  def edit; end

  def create
    @step_by_step_page = StepByStepPage.new(step_by_step_page_params)
    if @step_by_step_page.save
      update_downstream
      redirect_to @step_by_step_page, notice: 'Step by step page was successfully created.'
    else
      render :new
    end
  end

  def update
    if @step_by_step_page.update(step_by_step_page_params)
      update_downstream
      redirect_to step_by_step_page_path, notice: 'Step by step page was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @step_by_step_page.destroy
      discard_draft
      redirect_to step_by_step_pages_path, notice: 'Step by step page was successfully deleted.'
    else
      render :edit
    end
  end

  def publish
    set_current_page_as_step_by_step
    if request.post?
      @publish_intent = PublishIntent.new(params)
      if @publish_intent.valid?
        publish_page(@publish_intent)
        redirect_to @step_by_step_page, notice: "'#{@step_by_step_page.title}' has been published."
      end
    end
  end

  def unpublish
    set_current_page_as_step_by_step
    if request.post?
      redirect_url = params.delete("redirect_url")
      if StepByStepPage.validate_redirect(redirect_url)
        unpublish_page(redirect_url)
        redirect_to @step_by_step_page, notice: 'Step by step page was successfully unpublished.'
      else
        flash[:danger] = 'Redirect path is invalid. Step by step page has not been unpublished.'
      end
    end
  end

  def publish_or_delete
    @step_by_step_page = StepByStepPage.find(params[:step_by_step_page_id])
  end

  def check_links
    set_current_page_as_step_by_step
    @step_by_step_page.steps.each(&:request_broken_links)
  end

  def internal_change_notes
    set_current_page_as_step_by_step
    @internal_change_note = InternalChangeNote.new
  end

private

  def discard_draft
    StepNavPublisher.discard_draft(@step_by_step_page)
  rescue GdsApi::HTTPNotFound
    Rails.logger.info "Discarding #{@step_by_step_page.content_id} failed"
  end

  def update_downstream
    StepByStepDraftUpdateWorker.perform_async(@step_by_step_page.id)
  end

  def publish_page(publish_intent)
    StepNavPublisher.update(@step_by_step_page, publish_intent)
    StepNavPublisher.publish(@step_by_step_page)
    @step_by_step_page.mark_as_published
  end

  def unpublish_page(redirect_url)
    begin
      StepNavPublisher.unpublish(@step_by_step_page, redirect_url)
    rescue GdsApi::HTTPNotFound
      Rails.logger.info "Unpublishing #{@step_by_step_page.content_id} failed"
    end
    @step_by_step_page.mark_as_unpublished
  end

  def set_step_by_step_page
    @step_by_step_page = StepByStepPage.find(params[:id])
  end

  def step_by_step_page_params
    params.require(:step_by_step_page).permit(:title, :slug, :introduction, :description)
  end

  def set_current_page_as_step_by_step
    @step_by_step_page = StepByStepPage.find(params[:step_by_step_page_id])
  end
end
