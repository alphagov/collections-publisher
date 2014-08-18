class SectorsController < ApplicationController
  def index; end

private

  def subsectors
    @subsectors ||= Sector.all_children
  end
  helper_method :subsectors
end
