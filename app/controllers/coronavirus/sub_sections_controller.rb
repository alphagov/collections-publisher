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
        raise ActiveRecord::Rollback unless draft_updater.send
      end

      if draft_updater.errors.any?
        flash.now["alert"] = draft_updater.errors.to_sentence
        render :new, status: :internal_server_error
      else
        redirect_to coronavirus_page_path(page.slug), { notice: helpers.t("coronavirus.sub_sections.create.success") }
      end
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
        raise ActiveRecord::Rollback unless draft_updater.send
      end

      if draft_updater.errors.any?
        flash.now["alert"] = draft_updater.errors.to_sentence
        render :edit, status: :internal_server_error
      else
        redirect_to coronavirus_page_path(page.slug), { notice: helpers.t("coronavirus.sub_sections.update.success") }
      end
    end

    def destroy
      sub_section = page.sub_sections.find(params[:id])
      message = { notice: helpers.t("coronavirus.sub_sections.destroy.success") }

      SubSection.transaction do
        sub_section.destroy!

        unless draft_updater.send
          message = { alert: helpers.t("coronavirus.sub_sections.destroy.failed") }
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
