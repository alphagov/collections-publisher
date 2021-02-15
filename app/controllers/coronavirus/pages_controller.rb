module Coronavirus
  class PagesController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    before_action :redirect_to_index_if_slug_unknown, only: %w[prepare show]
    before_action :initialise_pages, only: %w[index]
    layout "admin_layout"

    def index
      @topic_page = Page.topic_page.first
      @subtopic_pages = Page.subtopic_pages
    end

    def prepare
      page
    end

    def show
      page
    end

    def update
      return slug_unknown_for_update if slug_unknown?

      message =
        draft_updater.send ? { notice: I18n.t("coronavirus.pages.actions.update.success") } : { alert: draft_updater.errors.to_sentence }
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

    def discard
      if draft_updater.discarded?
        Pages::DraftDiscarder.new(page).call
        message = { notice: I18n.t("coronavirus.pages.actions.discard_changes.success") }
      else
        message = { alert: draft_updater.errors.to_sentence }
      end
      redirect_to coronavirus_page_path(slug), message
    end

  private

    def initialise_pages
      page_configs.keys.map do |page|
        Pages::ModelBuilder.new(page.to_s).page
      end
    end

    def page
      @page ||= Pages::ModelBuilder.call(slug)
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end

    def slug_unknown_for_update
      message = I18n.t("coronavirus.pages.actions.update.failed.slug_unknown")
      redirect_to prepare_coronavirus_page_path, alert: message
    end

    def redirect_to_index_if_slug_unknown
      if slug_unknown?
        flash[:alert] = I18n.t("coronavirus.index.error", slug: slug)
        redirect_to coronavirus_pages_path
      end
    end

    def publish_page
      Services.publishing_api.publish(page.content_id, update_type)
      change_state("published")
      flash["notice"] = I18n.t("coronavirus.pages.actions.publish.success")
    rescue GdsApi::HTTPConflict
      flash["alert"] = I18n.t("coronavirus.pages.actions.publish.failed")
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
      params[:slug]
    end

    def slug_unknown?
      !page_configs.key?(slug.to_sym)
    end

    def page_configs
      Pages::Configuration.all_pages
    end

    def change_state(state)
      page.update(state: state)
    end
  end
end
