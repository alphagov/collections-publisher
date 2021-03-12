module Coronavirus
  class ReorderSubSectionsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def index
      page
    end

    def update
      SubSection.transaction do
        set_positions
        draft_updater.send
      end

      redirect_to coronavirus_page_path(page.slug), notice: helpers.t("coronavirus.reorder_sub_sections.update.success")
    rescue Pages::DraftUpdater::DraftUpdaterError => e
      message = helpers.t("coronavirus.reorder_sub_sections.update.failed", error: e.message)
      redirect_to reorder_coronavirus_page_sub_sections_path(page.slug), alert: message
    end

  private

    def page
      @page ||= Page.find_by!(slug: params[:page_slug])
    end

    def set_positions
      reordered_subsections = page.sub_sections.sort_by do |sub_section|
        params.require(:section_order_save).fetch(sub_section.id.to_s, sub_section.position).to_i
      end

      reordered_subsections.each.with_index(1) do |sub_section, index|
        sub_section.update_column(:position, index)
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
