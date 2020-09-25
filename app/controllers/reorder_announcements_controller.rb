class ReorderAnnouncementsController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  layout "admin_layout"

  def index
    coronavirus_page
  end

  def update; end

private

  def slug
    params[:slug] || params[:coronavirus_page_slug]
  end

  def coronavirus_page
    @coronavirus_page ||= CoronavirusPages::ModelBuilder.call(slug)
  end
end
