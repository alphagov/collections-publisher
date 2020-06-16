class SubSectionsController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  layout "admin_layout"

  def edit
    @coronavirus_page = CoronavirusPage.find_by(slug: params[:coronavirus_page_slug])
    @sub_section = @coronavirus_page.sub_sections.find(params[:id])
  end

  def update; end
end
