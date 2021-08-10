module Coronavirus
  class CoronavirusYamlsController < ApplicationController
    before_action :require_coronavirus_editor_permissions!
    layout "admin_layout"

    def new
      @coronavirus_yaml = page.coronavirus_yamls.new
    end

    def create
      @coronavirus_yaml = page.coronavirus_yamls.new(coronavirus_yaml_params)

      unless @coronavirus_yaml.valid?
        render :new, status: :unprocessable_entity
        return
      end

      CoronavirusYaml.transaction do
        @coronavirus_yaml.save!
      end

     redirect_to coronavirus_page_path(page.slug), notice: "saved"
    end


    private

    def page
      @page ||= Page.find_by(slug: params[:page_slug])
    end

    def coronavirus_yaml_params
      params.require(:coronavirus_yaml).permit(:content)
    end
  end
end
