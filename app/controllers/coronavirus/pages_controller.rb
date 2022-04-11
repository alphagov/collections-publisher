module Coronavirus
  class PagesController < ApplicationController
    before_action :require_coronavirus_editor_permissions!

    def index
      @topic_page = Page.find_by!(slug: "landing")
    end

    def edit_header
      page
    end

    def show
      page
    end

    def update_header
      @page = Page.find_by!(slug: "landing")
      @page.assign_attributes(landing_page_params)

      unless @page.valid?
        render :edit_header, status: :unprocessable_entity
        return
      end

      Page.transaction do
        @page.update!(landing_page_params)
        draft_updater.send
      end

      redirect_to coronavirus_page_path(@page.slug), notice: helpers.t("coronavirus.pages.update_header.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      flash.now[:alert] = e.message
      render :edit_header, status: :internal_server_error
    end

    def publish
      publish_page
      redirect_to coronavirus_page_path(page.slug)
    end

    def discard
      draft_updater.discard
      Pages::DraftDiscarder.new(page).call
      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.pages.discard.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      redirect_to coronavirus_page_path(page.slug), alert: e.message
    end

  private

    def page
      @page ||= Page.find_by!(slug: "landing")
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end

    def publish_page
      Services.publishing_api.publish(page.content_id, "minor")
      page.update!(state: "published")
      flash["notice"] = helpers.t("coronavirus.pages.publish.success")
    rescue GdsApi::HTTPConflict
      flash["alert"] = helpers.t("coronavirus.pages.publish.failed")
    end

    def landing_page_params
      params.require(:landing_page).permit(
        :header_title,
        :header_body,
        :header_link_url,
        :header_link_pre_wrap_text,
        :header_link_post_wrap_text,
      )
    end
  end
end
