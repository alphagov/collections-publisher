module Coronavirus
  class AnnouncementsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!

    def new
      @announcement = page.announcements.new
    end

    def create
      @announcement = page.announcements.new(announcement_params)
      unless @announcement.valid?
        render :new, status: :unprocessable_entity
        return
      end

      Announcement.transaction do
        @announcement.save!
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.announcements.create.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      flash.now[:alert] = e.message
      render :new, status: :internal_server_error
    end

    def destroy
      announcement = page.announcements.find(params[:id])

      Announcement.transaction do
        announcement.destroy!
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.announcements.destroy.success")
    rescue Pages::DraftUpdater::DraftUpdaterError
      redirect_to coronavirus_page_path(page.slug), alert: helpers.t("coronavirus.announcements.destroy.failed")
    end

    def edit
      @announcement = page.announcements.find(params[:id])
    end

    def update
      @announcement = page.announcements.find(params[:id])
      @announcement.assign_attributes(announcement_params)

      unless @announcement.valid?
        render :edit, status: :unprocessable_entity
        return
      end

      Announcement.transaction do
        @announcement.update!(announcement_params)
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.announcements.update.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      flash.now[:alert] = e.message
      render :edit, status: :internal_server_error
    end

  private

    def page
      @page ||= Page.find_by(slug: params[:page_slug])
    end

    def announcement_params
      params
        .require(:announcement)
        .permit(:title, :url, published_on: %i[day month year])
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(@page)
    end
  end
end
