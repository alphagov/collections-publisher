module Coronavirus
  class ReorderAnnouncementsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def index
      coronavirus_page
    end

    def update
      success = true
      reordered_announcements = JSON.parse(params[:announcement_order_save])

      Announcement.transaction do
        reordered_announcements.each do |announcement_data|
          announcement = coronavirus_page.announcements.find(announcement_data["id"])
          announcement.update_column(:position, announcement_data["position"])
        end

        unless draft_updater.send
          success = false
          raise ActiveRecord::Rollback
        end
      end

      if success
        message = "Announcements were successfully reordered."
        redirect_to coronavirus_page_path(coronavirus_page.slug), notice: message
      else
        message = "Sorry! Announcements have not been reordered: #{draft_updater.errors.to_sentence}."
        redirect_to reorder_coronavirus_page_announcements_path(coronavirus_page.slug), alert: message
      end
    end

  private

    def coronavirus_page
      @coronavirus_page ||= CoronavirusPage.find_by!(slug: params[:coronavirus_page_slug])
    end

    def draft_updater
      @draft_updater ||= CoronavirusPages::DraftUpdater.new(coronavirus_page)
    end
  end
end
