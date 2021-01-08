class TimelineEntriesController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  before_action :require_unreleased_feature_permissions!
  layout "admin_layout"

  def new
    @timeline_entry = coronavirus_page.timeline_entries.new
  end

private

  def coronavirus_page
    @coronavirus_page ||= CoronavirusPage.find_by(slug: params[:coronavirus_page_slug])
  end
end
