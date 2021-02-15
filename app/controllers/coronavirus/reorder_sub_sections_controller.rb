module Coronavirus
  class ReorderSubSectionsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def index
      page
    end

    def update
      success = true

      SubSection.transaction do
        set_positions

        unless draft_updater.send
          success = false
          raise ActiveRecord::Rollback
        end
      end

      if success
        message = I18n.t("coronavirus.reorder_sub_sections.success")
        redirect_to coronavirus_page_path(page.slug), notice: message
      else
        message = I18n.t("coronavirus.reorder_sub_sections.failed", error: draft_updater.errors.to_sentence)
        redirect_to reorder_coronavirus_page_sub_sections_path(page.slug), alert: message
      end
    end

  private

    def page
      @page ||= Page.find_by!(slug: params[:page_slug])
    end

    def set_positions
      reordered_subsections = JSON.parse(params[:section_order_save])
      reordered_subsections.each do |sub_section_data|
        sub_section = page.sub_sections.find(sub_section_data["id"])
        sub_section.update_column(:position, sub_section_data["position"])
      end
    end

    def draft_updater
      @draft_updater ||= Pages::DraftUpdater.new(page)
    end

    def page_configs
      Pages::Configuration.all_pages
    end
  end
end
