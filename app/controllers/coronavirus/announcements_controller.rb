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
      if @announcement.save && draft_updater.send
        redirect_to coronavirus_page_path(page.slug), notice: I18n.t("coronavirus.new_announcement.success")
      else
        render :new
      end
    end

    def destroy
      announcement = page.announcements.find(params[:id])
      message = { notice: I18n.t("coronavirus.summary.announcements.delete.success") }

      Announcement.transaction do
        announcement.destroy!

        unless draft_updater.send
          message = { alert: I18n.t("coronavirus.summary.announcements.delete.failed") }
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
        redirect_to coronavirus_page_path(page.slug), notice: I18n.t("coronavirus.edit_announcement.success")
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
