module Coronavirus
  class ReorderAnnouncementsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def index
      page
    end

    def update
      success = true
      reordered_announcements = JSON.parse(params[:announcement_order_save])

      Announcement.transaction do
        reordered_announcements.each do |announcement_data|
          announcement = page.announcements.find(announcement_data["id"])
          announcement.update_column(:position, announcement_data["position"])
        end

        unless draft_updater.send
          success = false
          raise ActiveRecord::Rollback
        end
      end

      if success
        message = helpers.t("coronavirus.reorder_announcements.success")
        redirect_to coronavirus_page_path(page.slug), notice: message
      else
        message = helpers.t("coronavirus.reorder_announcements.failed", error: draft_updater.errors.to_sentence)
        redirect_to reorder_coronavirus_page_announcements_path(page.slug), alert: message
      end
    end

  private

    def page
      @page ||= Page.find_by!(slug: params[:page_slug])
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end
  end
end
