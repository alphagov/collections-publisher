module Coronavirus
  class GithubChangesController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def index
      page
    end

    def update
      message = if draft_updater.send
                  { notice: "Draft content updated" }
                else
                  { alert: draft_updater.errors.to_sentence }
                end

      redirect_to github_changes_coronavirus_page_path(page.slug), message
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
      flash["notice"] = "Page published!"
    rescue GdsApi::HTTPConflict
      flash["alert"] = "You have already published this page."
    end

    def update_type
      major_update? ? "major" : "minor"
    end

    def major_update?
      params["update-type"] == "major"
    end
  end
end
