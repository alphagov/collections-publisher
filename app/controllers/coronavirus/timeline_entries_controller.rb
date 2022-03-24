module Coronavirus
  class TimelineEntriesController < ApplicationController
    before_action :require_coronavirus_editor_permissions!

    def new
      @timeline_entry = page.timeline_entries.new
    end

    def create
      @timeline_entry = page.timeline_entries.new(timeline_entry_params)

      unless @timeline_entry.valid?
        render :new, status: :unprocessable_entity
        return
      end

      TimelineEntry.transaction do
        @timeline_entry.save!
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: I18n.t("coronavirus.timeline_entries.create.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      flash.now[:alert] = e.message
      render :new, status: :internal_server_error
    end

    def edit
      @timeline_entry = page.timeline_entries.find(params[:id])
    end

    def update
      @timeline_entry = page.timeline_entries.find(params[:id])
      @timeline_entry.assign_attributes(timeline_entry_params)

      unless @timeline_entry.valid?
        render :edit, status: :unprocessable_entity
        return
      end

      TimelineEntry.transaction do
        @timeline_entry.update!(timeline_entry_params)
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: I18n.t("coronavirus.timeline_entries.update.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      flash.now[:alert] = e.message
      render :edit, status: :internal_server_error
    end

    def destroy
      timeline_entry = page.timeline_entries.find(params[:id])

      TimelineEntry.transaction do
        timeline_entry.destroy!
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: I18n.t("coronavirus.timeline_entries.destroy.success")
    rescue Pages::DraftUpdater::DraftUpdaterError
      redirect_to coronavirus_page_path(page.slug), alert: I18n.t("coronavirus.timeline_entries.destroy.failed")
    end

    helper_method :national_applicability_options
    def national_applicability_options
      Coronavirus::TimelineEntry::UK_NATIONS.map do |nation|
        {
          label: nation.titleize,
          value: nation,
          checked: @timeline_entry.national_applicability.include?(nation),
        }
      end
    end

  private

    def timeline_entry_params
      params.require(:timeline_entry).permit(:heading, :content, national_applicability: [])
    end

    def page
      @page ||= Page.find_by(slug: params[:page_slug])
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end
  end
end
