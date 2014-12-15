class MainstreamBrowsePagesController < ApplicationController
  expose(:mainstream_browse_pages)
  expose(:mainstream_browse_page)

  def index
    self.mainstream_browse_pages = MainstreamBrowsePage.only_parents
  end

  def show; end

  def new; end

  def create
    # Assigning the attributes directly, rather than using the 'attributes' key
    # in the `expose` method above, means that we can use the `mainstream_browse_page`
    # helper in other member actions.
    #
    # This is described in greater detail in this GitHub issue:
    # https://github.com/hashrocket/decent_exposure/issues/99#issuecomment-32115500
    #
    mainstream_browse_page.attributes = mainstream_browse_page_params

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

  def publish
    mainstream_browse_page.publish!
    PanopticonNotifier.publish_tag(
      MainstreamBrowsePagePresenter.new(mainstream_browse_page)
    )

    redirect_to mainstream_browse_page_path(mainstream_browse_page)
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
