class SectorsController < ApplicationController
  def index; end

  def publish
    sector = Sector.find(params[:sector_id])

    if sector
      flash[:success] = "Sector published"

      PublishingAPINotifier.publish(SectorPresenter.new(sector))
      sector.lists.each(&:mark_as_published!)

      redirect_to sector_lists_path(sector)
    else
      flash[:alert] = "Could not publish that sector"

      redirect_to sectors_path
    end
  end

private

  def grouped_subsectors
    subsectors.group_by(&:parent).sort_by {|parent, _| parent.title }
  end
  helper_method :grouped_subsectors

  def subsectors
    @subsectors ||= Sector.all_children
  end
end
