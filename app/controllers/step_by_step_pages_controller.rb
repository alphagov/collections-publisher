class StepByStepPagesController < ApplicationController
  before_action :require_gds_editor_permissions!

  def index; end
end
