class MainstreamBrowsePagesController < ApplicationController
  before_filter :require_gds_editor_permissions!

  def index
    @browse_pages = MainstreamBrowsePage.sorted_parents
  end

  def show
    @browse_page = find_browse_page
  end

  def edit
    @browse_page = find_browse_page
    @topics_for_select = topics_for_select
  end

  def update
    browse_page = find_browse_page

    if browse_page.update_attributes(browse_page_params)
      PanopticonNotifier.update_tag(MainstreamBrowsePagePresenter.new(browse_page))
      PublishingAPINotifier.send_to_publishing_api(browse_page)
      redirect_to browse_page
    else
      @browse_page = browse_page
      @topics_for_select = topics_for_select
      render :edit
    end
  end

  def new
    @browse_page = MainstreamBrowsePage.new(parent_id: params[:parent_id])
  end

  def create
    browse_page = MainstreamBrowsePage.new
    browse_page.attributes = browse_page_params

    if browse_page.save
      PanopticonNotifier.create_tag(MainstreamBrowsePagePresenter.new(browse_page))
      PublishingAPINotifier.send_to_publishing_api(browse_page)
      redirect_to browse_page
    else
      @browse_page = browse_page
      render 'new'
    end
  end

  def publish
    browse_page = find_browse_page

    browse_page.publish!
    PanopticonNotifier.publish_tag(MainstreamBrowsePagePresenter.new(browse_page))
    PublishingAPINotifier.send_to_publishing_api(browse_page)
    redirect_to browse_page
  end

private

  def topics_for_select
    Topic.includes(:parent).sort_by(&:title_including_parent)
  end

  def find_browse_page
    @_browse_page ||= MainstreamBrowsePage.find_by!(content_id: params[:id])
  end

  def browse_page_params
    # Convert the String ids to Topic objects so that
    # `update_attributes` correct updates and associates
    # them with the given `MainstreamBrowsePage` object.
    if params.require(:mainstream_browse_page).key? :topics
      topic_ids = params.require(:mainstream_browse_page)[:topics]
      topics = topic_ids.reject(&:blank?).map { |t| Topic.find(t) }
      tag_params.merge({"topics" => topics})
    else
      tag_params
    end
  end

  def tag_params
    params.require(:mainstream_browse_page)
      .permit(:slug, :title, :description, :parent_id)
  end
end
