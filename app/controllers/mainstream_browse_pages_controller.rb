class MainstreamBrowsePagesController < ApplicationController
  expose(:mainstream_browse_pages)
  expose(:mainstream_browse_page, attributes: :mainstream_browse_page_params)

  def index
    self.mainstream_browse_pages = MainstreamBrowsePage.only_parents
  end

  def show; end

  def new; end

  def create
    if mainstream_browse_page.save
      PanopticonNotifier.create_tag(
        MainstreamBrowsePagePresenter.new(mainstream_browse_page)
      )

      redirect_to mainstream_browse_pages_path
    else
      render action: :new
    end
  end

  def edit; end

  def update
    if mainstream_browse_page.update_attributes(mainstream_browse_page_params)
      PanopticonNotifier.update_tag(
        MainstreamBrowsePagePresenter.new(mainstream_browse_page)
      )

      redirect_to mainstream_browse_page_path(mainstream_browse_page)
    else
      render action: :edit
    end
  end

private
  def mainstream_browse_page_params
    params.require(:mainstream_browse_page).permit(:slug, :title, :description, :parent_id)
  end

  def parent
    @parent ||= MainstreamBrowsePage.only_parents.find_by_id(parent_id)
  end
  helper_method :parent

  def parent_id
    params[:parent_id] || params.fetch(:mainstream_browse_page, {})[:parent_id]
  end
end
