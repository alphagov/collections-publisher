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
        render :new
        return
      end

      SubSection.transaction do
        @sub_section.save!
        raise ActiveRecord::Rollback unless draft_updater.send
      end

      if draft_updater.errors.any?
        flash.now["alert"] = draft_updater.errors.to_sentence
        render :new
      else
        redirect_to coronavirus_page_path(page.slug), { notice: "Sub-section was successfully created." }
      end
    end

    def edit
      @sub_section = page.sub_sections.find(params[:id])
    end

    def update
      @sub_section = page.sub_sections.find(params[:id])
      @sub_section.assign_attributes(sub_section_params)

      unless @sub_section.valid?
        render :edit
        return
      end

      SubSection.transaction do
        @sub_section.save!
        raise ActiveRecord::Rollback unless draft_updater.send
      end

      if draft_updater.errors.any?
        flash.now["alert"] = draft_updater.errors.to_sentence
        render :edit
      else
        redirect_to coronavirus_page_path(page.slug), { notice: "Sub-section was successfully updated." }
      end
    end

    def destroy
      sub_section = page.sub_sections.find(params[:id])
      message = { notice: "Sub-section was successfully deleted." }

      SubSection.transaction do
        sub_section.destroy!

        unless draft_updater.send
          message = { alert: "Sub-section couldn't be deleted" }
          raise ActiveRecord::Rollback
        end
      end

      redirect_to coronavirus_page_path(page.slug), message
    end

  private

    def page
      @page ||= Page.find_by!(slug: params[:page_slug])
    end

    def sub_section_params
      params.require(:sub_section).permit(:title, :content, :featured_link)
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end
  end
end
