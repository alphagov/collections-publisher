module Coronavirus
  class AnnouncementsController < ApplicationController
    include DateFormatHelper
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

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
      message = { notice: helpers.t("coronavirus.announcements.destroy.success") }

      Announcement.transaction do
        announcement.destroy!

        unless draft_updater.send
          message = { alert: helpers.t("coronavirus.announcements.destroy.failed") }
          raise ActiveRecord::Rollback
        end
      end

      redirect_to coronavirus_page_path(page.slug), message
    end

    def edit
      @announcement = page.announcements.find(params[:id])
    end

    def update
      @announcement = page.announcements.find(params[:id])

      if @announcement.update(announcement_params) && draft_updater.send
        redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.announcements.update.success")
      else
        render :edit
      end
    end

  private

    def page
      @page ||= Page.find_by(slug: params[:page_slug])
    end

    def announcement_params
      params.require(:announcement)
      .permit(:title, :path, :published_at)
      .merge(format_published_at(
               params["announcement"]["published_at"]["day"],
               params["announcement"]["published_at"]["month"],
               params["announcement"]["published_at"]["year"],
             ))
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(@page)
    end
  end
end
