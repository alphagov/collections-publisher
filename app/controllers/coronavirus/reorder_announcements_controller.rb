module Coronavirus
  class ReorderAnnouncementsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def index
      page
    end

    def update
      success = true

      reordered_announcements = page.announcements.sort_by do |announcement|
        params.require(:announcement_order_save).fetch(announcement.id.to_s, announcement.position).to_i
      end

      Announcement.transaction do
        reordered_announcements.each.with_index(1) do |announcement, index|
          announcement.update_column(:position, index)
        end

        unless draft_updater.send
          success = false
          raise ActiveRecord::Rollback
        end
      end

      if success
        message = "Announcements were successfully reordered."
        redirect_to coronavirus_page_path(page.slug), notice: message
      else
        message = "Sorry! Announcements have not been reordered: #{draft_updater.errors.to_sentence}."
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
