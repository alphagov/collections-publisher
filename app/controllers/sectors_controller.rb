class SectorsController < ApplicationController
  def index; end

private

  def subsectors
    @subsectors ||= Sector.all_having_parents
  end
  helper_method :subsectors
end
