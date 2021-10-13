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
      draft_updater.discard
      Pages::DraftDiscarder.new(page).call
      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.pages.discard.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      redirect_to coronavirus_page_path(page.slug), alert: e.message
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
      Pages::ModelBuilder.new("landing").page
    end
  end
end
