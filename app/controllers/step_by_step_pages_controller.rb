class StepByStepPagesController < ApplicationController
  include PublishingApiHelper
  layout 'admin_layout'

  before_action :require_gds_editor_permissions!
  before_action :require_scheduling_permissions!, only: %i[schedule unschedule]
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
        custom_note = " with note: #{@publish_intent.change_note}" unless @publish_intent.change_note.empty?
        note_description = "#{@publish_intent.update_type.capitalize} update published by #{current_user.name}#{custom_note}"
        generate_internal_change_note(note_description)
        set_change_note_version
        redirect_to @step_by_step_page, notice: "'#{@step_by_step_page.title}' has been published."
      end
    end
  end

  def schedule
    set_current_page_as_step_by_step
    if request.post?
      if @step_by_step_page.update_attributes(scheduled_at: params[:scheduled_at])
        schedule_to_publish
        note_description = "Minor update scheduled by #{current_user.name} for publishing at #{params[:scheduled_at]}"
        generate_internal_change_note(note_description)
        set_change_note_version
        redirect_to @step_by_step_page, notice: "'#{@step_by_step_page.title}' has been scheduled to publish."
      else
        render :schedule
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
        flash[:alert] = 'Redirect path is invalid. Step by step page has not been unpublished.'
      end
    end
  end

  def unschedule
    set_current_page_as_step_by_step
    @step_by_step_page.update(scheduled_at: nil)
    unschedule_publishing
    note_description = "Publishing was unscheduled by #{current_user.name}."
    generate_internal_change_note(note_description)
    set_change_note_version
    redirect_to @step_by_step_page, notice: "Publishing of '#{@step_by_step_page.title}' has been unscheduled."
  end

  def revert
    set_current_page_as_step_by_step
    if request.post?
      discard_draft
      revert_page
      redirect_to @step_by_step_page, notice: 'Draft successfully discarded.'
    else
      render :edit
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
    @step_by_step_page.discard_notes
    StepNavPublisher.discard_draft(@step_by_step_page)
  rescue GdsApi::HTTPNotFound
    Rails.logger.info "Discarding #{@step_by_step_page.content_id} failed"
  end

  def update_downstream
    StepByStepDraftUpdateWorker.perform_async(@step_by_step_page.id, current_user.name)
  end

  def publish_page(publish_intent)
    StepNavPublisher.update(@step_by_step_page, publish_intent)
    StepNavPublisher.publish(@step_by_step_page)
    @step_by_step_page.mark_as_published
  end

  def schedule_to_publish
    StepNavPublisher.schedule_for_publishing(@step_by_step_page)
  end

  def unpublish_page(redirect_url)
    begin
      StepNavPublisher.unpublish(@step_by_step_page, redirect_url)
    rescue GdsApi::HTTPNotFound
      Rails.logger.info "Unpublishing #{@step_by_step_page.content_id} failed"
    end
    @step_by_step_page.mark_as_unpublished
  end

  def unschedule_publishing
    StepNavPublisher.cancel_scheduling(@step_by_step_page)
  end

  def revert_page
    published_version = latest_edition_number(@step_by_step_page.content_id, publication_state: "published")
    payload = Services.publishing_api.get_content(@step_by_step_page.content_id, version: published_version).to_hash

    StepByStepPageReverter.new(@step_by_step_page, payload).repopulate_from_publishing_api
  end

  def generate_internal_change_note(note_description)
    change_note = @step_by_step_page.internal_change_notes.new(
      author: current_user.name,
      description: note_description
    )
    change_note.save!
  end

  def set_change_note_version
    change_notes = @step_by_step_page.internal_change_notes.where(edition_number: nil)
    change_notes.update_all(edition_number: latest_edition_number(@step_by_step_page.content_id))
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
