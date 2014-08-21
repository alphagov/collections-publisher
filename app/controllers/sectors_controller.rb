class SectorsController < ApplicationController
  def index; end

  def publish
    sector = Sector.find(params[:sector_id])

    if sector
      flash[:notice] = "Sector published"

      PublishingAPINotifier.publish(SectorPresenter.new(sector))
      sector.lists.each(&:mark_as_published!)

      redirect_to sector_lists_path(sector)
    else
      flash[:alert] = "Could not publish that sector"

      redirect_to sectors_path
    end
  end

private

  def subsectors
    @subsectors ||= Sector.all_children
  end
  helper_method :subsectors
end
