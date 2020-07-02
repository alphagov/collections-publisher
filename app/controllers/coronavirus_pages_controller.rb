class CoronavirusPagesController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  before_action :require_unreleased_feature_permissions!, only: %w[show reorder]
  before_action :redirect_to_index_if_slug_unknown, only: %w[prepare show]
  before_action :initialise_coronavirus_pages, only: %w[index]
  layout "admin_layout"

  def index
    @topic_page = CoronavirusPage.topic_page.first
    @subtopic_pages = CoronavirusPage.subtopic_pages
  end

  def prepare
    coronavirus_page
  end

  def show
    coronavirus_page
  end

  def update
    return slug_unknown_for_update if slug_unknown?

    message =
      draft_updater.send ? { notice: "Draft content updated" } : { alert: draft_updater.errors.to_sentence }
    redirect_to prepare_coronavirus_page_path(slug), message
  end

  def publish
    publish_page
    if URI(request.referer).path == prepare_coronavirus_page_path(slug)
      redirect_to prepare_coronavirus_page_path(slug)
    else
      redirect_to coronavirus_page_path(slug)
    end
  end

  def reorder
    coronavirus_page
    @old_positions = positions
    if request.post? && params.key?(:section_order_save)
      @new_positions = JSON.parse(params[:section_order_save])
      set_positions(@new_positions)
      if draft_updater.send
        message = { notice: "Sections were successfully reordered." }
      else
        set_positions(@old_positions)
        message = { alert: "Sorry! Sections have not been reordered: " + draft_updater.errors.to_sentence }
      end
      redirect_to coronavirus_page_path(slug), message
    end
  end

private

  def positions
    coronavirus_page.sub_sections.each_with_object([]) do |sub_section, array|
      array << { "id" => sub_section.id, "position" => sub_section.position }
    end
  end

  def set_positions(positions)
    positions.each do |sub_section|
      SubSection.find(sub_section["id"]).update(position: sub_section["position"])
    end
  end

  def initialise_coronavirus_pages
    page_configs.keys.map do |page|
      CoronavirusPages::ModelBuilder.new(page.to_s).page
    end
  end

  def coronavirus_page
    @coronavirus_page ||= CoronavirusPages::ModelBuilder.call(slug)
  end

  def draft_updater
    @draft_updater ||= CoronavirusPages::DraftUpdater.new(coronavirus_page)
  end

  def slug_unknown_for_update
    message = "Page could not be updated because the configuration cannot be found."
    redirect_to prepare_coronavirus_page_path, alert: message
  end

  def redirect_to_index_if_slug_unknown
    if slug_unknown?
      flash[:alert] = "'#{slug}' is not a valid page.  Please select from one of those below."
      redirect_to coronavirus_pages_path
    end
  end

  def publish_page
    Services.publishing_api.publish(coronavirus_page.content_id, update_type)

    flash["notice"] = "Page published!"
  rescue GdsApi::HTTPConflict
    flash["alert"] = "Page already published - update the draft first"
  end

  def with_longer_timeout
    prior_timeout = Services.publishing_api.client.options[:timeout]
    Services.publishing_api.client.options[:timeout] = 10

    begin
      yield
    ensure
      Services.publishing_api.client.options[:timeout] = prior_timeout
    end
  end

  def update_type
    major_update? ? "major" : "minor"
  end

  def major_update?
    params["update-type"] == "major"
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
