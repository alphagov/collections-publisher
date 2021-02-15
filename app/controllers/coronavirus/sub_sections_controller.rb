module Coronavirus
  class SubSectionsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def new
      @sub_section = page.sub_sections.new
    end

    def create
      @sub_section = page.sub_sections.new(sub_section_params)
      if @sub_section.save && draft_updater.send
        redirect_to coronavirus_page_path(page.slug), notice: I18n.t("coronavirus.pages.sub_sections.new.success")
      else
        @sub_section.errors.add :base, draft_updater.errors.to_sentence
        render :new
      end
    end

    def edit
      @sub_section = page.sub_sections.find(params[:id])
    end

    def update
      @sub_section = page.sub_sections.find(params[:id])
      if @sub_section.update(sub_section_params) && draft_updater.send
        redirect_to coronavirus_page_path(page.slug), notice: I18n.t("coronavirus.pages.sub_sections.edit.success")
      else
        @sub_section.errors.add :base, draft_updater.errors.to_sentence
        render :edit
      end
    end

    def destroy
      sub_section = page.sub_sections.find(params[:id])
      message = { notice: I18n.t("coronavirus.summary.sub_sections.delete.success") }

      SubSection.transaction do
        sub_section.destroy!

        unless draft_updater.send
          message = { alert: I18n.t("coronavirus.summary.sub_sections.delete.failed") }
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
