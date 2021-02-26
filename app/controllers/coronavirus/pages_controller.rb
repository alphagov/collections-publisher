module Coronavirus
  class PagesController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
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
      redirect_to coronavirus_page_path(page.slug)
    end

    def discard
      if draft_updater.discarded?
        Pages::DraftDiscarder.new(page).call
        message = { notice: helpers.t("coronavirus.pages.discard.success") }
      else
        message = { alert: draft_updater.errors.to_sentence }
      end
      redirect_to coronavirus_page_path(page.slug), message
    end

  private

    def page
      @page ||= Page.find_by!(slug: params[:slug])
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end

    def publish_page
      Services.publishing_api.publish(page.content_id, "minor")
      page.update!(state: "published")
      flash["notice"] = helpers.t("coronavirus.pages.publish.success")
    rescue GdsApi::HTTPConflict
      flash["alert"] = helpers.t("coronavirus.pages.publish.failed")
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
