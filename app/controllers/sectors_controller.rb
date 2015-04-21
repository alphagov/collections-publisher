class SectorsController < ApplicationController
  def index
    subtopics = Topic.only_children.includes(:parent).order(:title)
    @grouped_topics = subtopics.group_by(&:parent).sort_by {|parent, _| parent.title }
  end

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
end
