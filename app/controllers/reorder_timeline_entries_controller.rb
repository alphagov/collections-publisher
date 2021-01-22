class ReorderTimelineEntriesController < ApplicationController
  before_action :require_unreleased_feature_permissions!
  before_action :require_coronavirus_editor_permissions!
  layout "admin_layout"

  def index
    coronavirus_page
  end

  def update
    success = true
    reordered_timeline_entries = JSON.parse(params[:timeline_entry_order_save])

    TimelineEntry.transaction do
      reordered_timeline_entries.each do |timeline_entry_data|
        timeline_entry = coronavirus_page.timeline_entries.find(timeline_entry_data["id"])
        timeline_entry.update_column(:position, timeline_entry_data["position"])
      end

      unless draft_updater.send
        success = false
        raise ActiveRecord::Rollback
      end
    end

    if success
      message = I18n.t("coronavirus_pages.timeline_entries.reorder.success")
      redirect_to coronavirus_page_path(coronavirus_page.slug), notice: message
    else
      message = I18n.t("coronavirus_pages.timeline_entries.reorder.error", error: draft_updater.errors.to_sentence)
      redirect_to reorder_coronavirus_page_timeline_entries_path(coronavirus_page.slug), alert: message
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
