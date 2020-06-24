class SubSectionsController < ApplicationController
  before_action :require_unreleased_feature_permissions!
  layout "admin_layout"

  def new
    @coronavirus_page = CoronavirusPage.find_by(slug: params[:coronavirus_page_slug])
    @sub_section = @coronavirus_page.sub_sections.new
  end

  def create
    @coronavirus_page = CoronavirusPage.find_by(slug: params[:coronavirus_page_slug])
    @sub_section = @coronavirus_page.sub_sections.new(sub_section_params)
    if @sub_section.save
      redirect_to coronavirus_page_path(@coronavirus_page.slug), notice: "Sub-section was successfully created."
    else
      render :new
    end
  end

  def edit
    @coronavirus_page = CoronavirusPage.find_by(slug: params[:coronavirus_page_slug])
    @sub_section = @coronavirus_page.sub_sections.find(params[:id])
  end

  def update
    @sub_section = SubSection.find(params[:id])
    @coronavirus_page = @sub_section.coronavirus_page
    if @sub_section.update(sub_section_params)
      redirect_to coronavirus_page_path(@coronavirus_page.slug), notice: "Sub-section was successfully updated."
    else
      render :edit
    end
  end

  def sub_section_params
    params.require(:sub_section).permit(:title, :content)
  end
end
