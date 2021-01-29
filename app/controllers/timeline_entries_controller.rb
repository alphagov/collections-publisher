class TimelineEntriesController < ApplicationController
  before_action :require_coronavirus_editor_permissions!
  before_action :require_unreleased_feature_permissions!
  layout "admin_layout"

  def new
    @timeline_entry = coronavirus_page.timeline_entries.new
  end

  def create
    @timeline_entry = coronavirus_page.timeline_entries.new(timeline_entry_params)

    if @timeline_entry.save && draft_updater.send
      redirect_to coronavirus_page_path(coronavirus_page.slug), notice: "Timeline entry was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @timeline_entry = coronavirus_page.timeline_entries.find(params[:id])
  end

  def update
    @timeline_entry = coronavirus_page.timeline_entries.find(params[:id])

    if @timeline_entry.update(timeline_entry_params) && draft_updater.send
      redirect_to coronavirus_page_path(coronavirus_page.slug), notice: "Timeline entry was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    timeline_entry = coronavirus_page.timeline_entries.find(params[:id])
    message = { notice: I18n.t("coronavirus_pages.timeline_entries.delete.success") }

    TimelineEntry.transaction do
      timeline_entry.destroy!

      unless draft_updater.send
        message = { alert: I18n.t("coronavirus_pages.timeline_entries.delete.failed") }
        raise ActiveRecord::Rollback
      end
    end

    redirect_to coronavirus_page_path(@coronavirus_page.slug), message
  end

private

  def timeline_entry_params
    params.require(:timeline_entry).permit(:heading, :content)
  end

  def coronavirus_page
    @coronavirus_page ||= CoronavirusPage.find_by(slug: params[:coronavirus_page_slug])
  end

  def draft_updater
    @draft_updater ||= CoronavirusPages::DraftUpdater.new(coronavirus_page)
  end
end
