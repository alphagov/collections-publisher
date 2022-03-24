module Coronavirus
  class ReorderTimelineEntriesController < ApplicationController
    before_action :require_coronavirus_editor_permissions!

    def index
      page
    end

    def update
      reordered_timeline_entries = page.timeline_entries.sort_by do |entry|
        params.require(:timeline_entry_order_save).fetch(entry.id.to_s, entry.position).to_i
      end

      TimelineEntry.transaction do
        reordered_timeline_entries.each.with_index(1) do |entry, index|
          entry.update_column(:position, index)
        end

        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.reorder_timeline_entries.update.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      message = helpers.t("coronavirus.reorder_timeline_entries.update.failed", error: e.message)
      redirect_to reorder_coronavirus_page_timeline_entries_path(page.slug), alert: message
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
