module Coronavirus
  class ReorderAnnouncementsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!

    def index
      page
    end

    def update
      reordered_announcements = page.announcements.sort_by do |announcement|
        params.require(:announcement_order_save).fetch(announcement.id.to_s, announcement.position).to_i
      end

      Announcement.transaction do
        reordered_announcements.each.with_index(1) do |announcement, index|
          announcement.update_column(:position, index)
        end

        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.reorder_announcements.update.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      message = helpers.t("coronavirus.reorder_announcements.update.failed", error: e.message)
      redirect_to reorder_coronavirus_page_announcements_path(page.slug), alert: message
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
