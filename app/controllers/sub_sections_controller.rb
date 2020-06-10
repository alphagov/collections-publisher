class SubSectionsController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  layout "admin_layout"

  def edit; end

  def update; end
end
