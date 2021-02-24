module Coronavirus
  class PagesController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    before_action :redirect_to_index_if_slug_unknown, only: %w[show]
    before_action :initialise_pages, only: %w[index]
    layout "admin_layout"

    def index
      @topic_page = Page.topic_page.first
      @subtopic_pages = Page.subtopic_pages
    end

    def show
      page
    end

    def publish
      publish_page
      redirect_to coronavirus_page_path(slug)
    end

    def discard
      if draft_updater.discarded?
        Pages::DraftDiscarder.new(page).call
        message = { notice: "Changes to subsections have been discarded" }
      else
        message = { alert: draft_updater.errors.to_sentence }
      end
      redirect_to coronavirus_page_path(slug), message
    end

  private

    def page
      @page ||= Pages::ModelBuilder.call(slug)
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end

    def publish_page
      Services.publishing_api.publish(page.content_id, "minor")
      page.update!(state: "published")
      flash["notice"] = "Page published!"
    rescue GdsApi::HTTPConflict
      flash["alert"] = "You have already published this page."
    end

    def slug
      params[:slug]
    end

    def redirect_to_index_if_slug_unknown
      if slug_unknown?
        flash[:alert] = "'#{slug}' is not a valid page.  Please select from one of those below."
        redirect_to coronavirus_pages_path
      end
    end

    def slug_unknown?
      !page_configs.key?(slug.to_sym)
    end

    def initialise_pages
      page_configs.keys.map do |page_config|
        Pages::ModelBuilder.new(page_config.to_s).page
      end
    end

    def page_configs
      Pages::Configuration.all_pages
    end
  end
end
