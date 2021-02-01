module Coronavirus
  class SubSectionsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def new
      @sub_section = coronavirus_page.sub_sections.new
    end

    def create
      @sub_section = coronavirus_page.sub_sections.new(sub_section_params)
      if @sub_section.save && draft_updater.send
        redirect_to coronavirus_page_path(coronavirus_page.slug), notice: "Sub-section was successfully created."
      else
        @sub_section.errors.add :base, draft_updater.errors.to_sentence
        render :new
      end
    end

    def edit
      @sub_section = coronavirus_page.sub_sections.find(params[:id])
    end

    def update
      @sub_section = coronavirus_page.sub_sections.find(params[:id])
      if @sub_section.update(sub_section_params) && draft_updater.send
        redirect_to coronavirus_page_path(coronavirus_page.slug), notice: "Sub-section was successfully updated."
      else
        @sub_section.errors.add :base, draft_updater.errors.to_sentence
        render :edit
      end
    end

    def destroy
      sub_section = coronavirus_page.sub_sections.find(params[:id])
      message = { notice: "Sub-section was successfully deleted." }

      SubSection.transaction do
        sub_section.destroy!

        unless draft_updater.send
          message = { alert: "Sub-section couldn't be deleted" }
          raise ActiveRecord::Rollback
        end
      end

      redirect_to coronavirus_page_path(coronavirus_page.slug), message
    end

  private

    def coronavirus_page
      @coronavirus_page ||= CoronavirusPage.find_by!(slug: params[:coronavirus_page_slug])
    end

    def sub_section_params
      params.require(:sub_section).permit(:title, :content, :featured_link)
    end

    def draft_updater
      @draft_updater ||= CoronavirusPages::DraftUpdater.new(@coronavirus_page)
    end
  end
end
