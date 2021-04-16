module Coronavirus
  class SubSectionsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def new
      @sub_section = page.sub_sections.new
    end

    def create
      @sub_section = page.sub_sections.new(sub_section_params)

      unless @sub_section.valid?
        render :new, status: :unprocessable_entity
        return
      end

      SubSection.transaction do
        @sub_section.save!
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.sub_sections.create.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      flash.now[:alert] = e.message
      render :new, status: :internal_server_error
    end

    def edit
      @sub_section = page.sub_sections.find(params[:id])
    end

    def update
      @sub_section = page.sub_sections.find(params[:id])
      @sub_section.assign_attributes(sub_section_params)

      unless @sub_section.valid?
        render :edit, status: :unprocessable_entity
        return
      end

      SubSection.transaction do
        @sub_section.save!
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.sub_sections.update.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      flash.now[:alert] = e.message
      render :edit, status: :internal_server_error
    end

    def destroy
      sub_section = page.sub_sections.find(params[:id])

      SubSection.transaction do
        sub_section.destroy!
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.sub_sections.destroy.success")
    rescue Pages::DraftUpdater::DraftUpdaterError
      redirect_to coronavirus_page_path(page.slug), alert: helpers.t("coronavirus.sub_sections.destroy.failed")
    end

  private

    def page
      @page ||= Page.find_by!(slug: params[:page_slug])
    end

    def sub_section_params
      params.require(:sub_section).permit(:title, :content, :action_link_url, :action_link_content, :action_link_summary)
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end
  end
end
