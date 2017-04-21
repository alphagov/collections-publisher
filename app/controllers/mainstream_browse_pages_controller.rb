class MainstreamBrowsePagesController < ApplicationController
  before_action :require_gds_editor_permissions!
  before_action :protect_archived_browse_pages!, only: %i[edit update publish]

  def index
    @browse_pages = MainstreamBrowsePage.sorted_parents
  end

  def show
    @browse_page = find_browse_page
    render 'archived_browse_page' if @browse_page.archived?
  end

  def edit
    @browse_page = find_browse_page
    @topics_for_select = topics_for_select
  end

  def update
    browse_page = find_browse_page

    if browse_page.update_attributes(browse_page_params)
      TagUpdateBroadcaster.broadcast(browse_page)
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
      TagCreateBroadcaster.broadcast(browse_page)
      redirect_to browse_page
    else
      @browse_page = browse_page
      render 'new'
    end
  end

  def publish
    browse_page = find_browse_page
    TagPublisher.new(browse_page).publish
    redirect_to browse_page
  end

  def propose_archive
    @archival = MainstreamBrowsePageArchivalForm.new(tag: find_browse_page)
  end

  def archive
    @archival = MainstreamBrowsePageArchivalForm.new(mainstream_browse_page_archival_form_params)
    @archival.tag = find_browse_page

    if @archival.archive_or_remove
      redirect_to mainstream_browse_pages_path, success: 'The mainstream browse page has been archived or removed.'
    else
      render 'propose_archive'
    end
  end

  def manage_child_ordering
    @browse_page = find_browse_page
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
    # `update_attributes` correctly updates and associates
    # them with the given `MainstreamBrowsePage` object.
    if params.require(:mainstream_browse_page).key? :topics
      topic_ids = params.require(:mainstream_browse_page)[:topics]
      topics = topic_ids.reject(&:blank?).map { |t| Topic.find(t) }
      tag_params.merge("topics" => topics)
    else
      tag_params
    end
  end

  def mainstream_browse_page_archival_form_params
    params
      .fetch(:mainstream_browse_page_archival_form, {})
      .permit(:tag, :successor, :successor_path)
  end

  def tag_params
    params.require(:mainstream_browse_page)
      .permit(:slug, :title, :description, :parent_id, :child_ordering, children_attributes: [:index, :id])
  end

  def protect_archived_browse_pages!
    browse_page = find_browse_page
    if browse_page.archived?
      flash[:danger] = 'You cannot modify an archived mainstream browse page.'
      redirect_to browse_page
    end
  end
end
