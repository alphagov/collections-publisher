class SecondaryContentLinksController < ApplicationController
  before_action :require_gds_editor_permissions!

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
end
