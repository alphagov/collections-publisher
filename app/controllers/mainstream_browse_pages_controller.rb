class MainstreamBrowsePagesController < ApplicationController
  expose(:mainstream_browse_pages)
  expose(:mainstream_browse_page, attributes: :mainstream_browse_page_params)

  def index; end

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
    params.require(:mainstream_browse_page).permit(:slug, :title, :description)
  end

end
