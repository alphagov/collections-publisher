class MainstreamBrowsePagesController < ApplicationController
  before_action :require_gds_editor_permissions!
  before_action :protect_archived_browse_pages!, only: %i[edit update publish]

  def index
    @browse_pages = MainstreamBrowsePage.sorted_level_one
  end

  def show
    @browse_page = find_browse_page
    render "archived_browse_page" if @browse_page.archived?
  end

  def edit
    @browse_page = find_browse_page
  end

  def update
    browse_page = find_browse_page

    if browse_page.update(browse_page_params)
      TagBroadcaster.broadcast(browse_page)
      redirect_to browse_page
    else
      @browse_page = browse_page
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
      TagBroadcaster.broadcast(browse_page)
      redirect_to browse_page
    else
      @browse_page = browse_page
      render "new"
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
      redirect_to mainstream_browse_pages_path, notice: "The mainstream browse page has been archived or removed."
    else
      render :propose_archive
    end
  end

  def manage_child_ordering
    @browse_page = find_browse_page
  end

  def update_child_ordering
    @browse_page = find_browse_page

    if @browse_page.update(manage_child_ordering_params)
      TagBroadcaster.broadcast(@browse_page)
      redirect_to @browse_page
    else
      render :manage_child_ordering
    end
  end

  helper_method :errors_for
  def errors_for(object, attribute)
    object.errors.errors.filter_map do |error|
      if error.attribute == attribute
        {
          text: error.options[:message],
        }
      end
    end
  end

private

  def find_browse_page
    @find_browse_page ||= MainstreamBrowsePage.find_by!(content_id: params[:id])
  end

  def browse_page_params
    tag_params
  end

  def mainstream_browse_page_archival_form_params
    params
      .fetch(:mainstream_browse_page_archival_form, {})
      .permit(:tag, :successor, :successor_path)
  end

  def tag_params
    params.require(:mainstream_browse_page)
      .permit(:slug, :title, :description, :parent_id)
  end

  def manage_child_ordering_params
    params.require(:mainstream_browse_page)
      .permit(:child_ordering)
      .merge(children_params)
  end

  def children_params
    return unless params.dig("mainstream_browse_page", "child_ordering") == "curated"

    children_attributes_hash = {}

    params[:ordering].each do |input|
      child_id, order = input
      children_attributes_hash[order] = { "index" => order, "id" => child_id }
    end

    { children_attributes: children_attributes_hash }
  end

  def protect_archived_browse_pages!
    browse_page = find_browse_page
    if browse_page.archived?
      flash[:alert] = "You cannot modify an archived mainstream browse page."
      redirect_to browse_page
    end
  end
end
