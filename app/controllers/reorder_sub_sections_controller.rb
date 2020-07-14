class ReorderSubSectionsController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  before_action :require_unreleased_feature_permissions!
  before_action :redirect_to_index_if_slug_unknown
  layout "admin_layout"

  def index
    coronavirus_page
  end

  def update
    current_positions
    set_positions(submitted_positions)
    if draft_updater.send
      redirect_to coronavirus_page_path(slug), notice: "Sections were successfully reordered."
    else
      message = "Sorry! Sections have not been reordered: #{draft_updater.errors.to_sentence}."
      redirect_to reorder_coronavirus_page_sub_sections_path(slug), alert: message
    end
  end

private

  def coronavirus_page
    @coronavirus_page ||= CoronavirusPages::ModelBuilder.call(slug)
  end

  def current_positions
    @current_positions ||= coronavirus_page.sub_sections.map do |sub_section|
      { "id" => sub_section.id, "position" => sub_section.position }
    end
  end

  def submitted_positions
    JSON.parse(params[:section_order_save])
  end

  def set_positions(positions)
    positions.each do |sub_section|
      SubSection.find(sub_section["id"]).update(position: sub_section["position"])
    end
  end

  def draft_updater
    @draft_updater ||= CoronavirusPages::DraftUpdater.new(coronavirus_page)
  end

  def redirect_to_index_if_slug_unknown
    if slug_unknown?
      flash[:alert] = "'#{slug}' is not a valid page.  Please select from one of those below."
      redirect_to coronavirus_pages_path
    end
  end

  def slug
    params[:slug] || params[:coronavirus_page_slug]
  end

  def slug_unknown?
    !page_configs.key?(slug.to_sym)
  end

  def page_configs
    CoronavirusPages::Configuration.all_pages
  end
end
