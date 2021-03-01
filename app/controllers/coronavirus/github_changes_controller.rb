module Coronavirus
  class GithubChangesController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def index
      page
    end

    def update
      draft_updater.send

      redirect_to github_changes_coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.github_changes.update.success")
    rescue Coronavirus::Pages::DraftUpdater::PayloadInvalidError => e
      redirect_to github_changes_coronavirus_page_path(page.slug), alert: e.message
    end

    def publish
      publish_page
      redirect_to github_changes_coronavirus_page_path(page.slug)
    end

  private

    def page
      @page ||= Page.find_by(slug: params[:slug])
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end

    def publish_page
      Services.publishing_api.publish(page.content_id, update_type)
      page.update!(state: "published")
      flash["notice"] = helpers.t("coronavirus.github_changes.publish.success")
    rescue GdsApi::HTTPConflict
      flash["alert"] = helpers.t("coronavirus.github_changes.publish.failed")
    end

    def update_type
      major_update? ? "major" : "minor"
    end

    def major_update?
      params["update-type"] == "major"
    end
  end
end
