class SecondaryContentLinksController < ApplicationController
  layout "admin_layout"
  before_action :require_gds_editor_permissions!

  def create
    @secondary_content_link = step_by_step_page.secondary_content_links.new(content_item)

    if @secondary_content_link.save
      update_downstream

      redirect_to step_by_step_page_secondary_content_links_path(step_by_step_page.id), notice: "Secondary content was successfully linked."
    else
      flash[:alert] = @error if @error
      redirect_to step_by_step_page_secondary_content_links_path(step_by_step_page.id)
    end
  end

  def destroy
    if secondary_content_link.destroy
      update_downstream

      redirect_to step_by_step_page_secondary_content_links_path(step_by_step_page.id), notice: "Secondary content link was successfully deleted."
    else
      redirect_to step_by_step_page_secondary_content_links_path(step_by_step_page.id)
    end
  end

  def index
    @secondary_content_link = step_by_step_page.secondary_content_links.new
    @secondary_content_links = step_by_step_page.secondary_content_links.all
  end

private

  def step_by_step_page
    @step_by_step_page ||= StepByStepPage.find(params[:step_by_step_page_id])
  end

  def secondary_content_link
    @secondary_content_link ||= step_by_step_page.secondary_content_links.find(params[:id])
  end

  def update_downstream
    StepByStepDraftUpdateWorker.perform_async(step_by_step_page.id, current_user.name)
  end

  def content_item
    base_path = params[:base_path].gsub(/^\s+|\s+$/, "")
    base_path = URI.parse(base_path).path
    content_id = Services.publishing_api.lookup_content_id(base_path: base_path, with_drafts: true)

    if content_id.nil?
      @error = "#{base_path} doesn't exist on GOV.UK."
      return {}
    end

    content_item = Services.publishing_api.get_content(content_id)

    {
      base_path: content_item["base_path"],
      title: content_item["title"],
      content_id: content_id,
      publishing_app: content_item["publishing_app"],
      schema_name: content_item["schema_name"],
    }
  end
end
