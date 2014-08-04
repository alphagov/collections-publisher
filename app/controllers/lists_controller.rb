class ListsController < ApplicationController
  expose(:sector)
  expose(:lists, ancestor: :sector)
  expose(:list, attributes: :list_params)

  def index; end

  def create
    list.sector_id = sector.slug

    if list.save
      flash[:notice] = 'List created'
    else
      flash[:error] = 'Could not create your list'
    end

    redirect_to sector_lists_path(sector)
  end

private

  def list_params
    params.require(:list).permit(:name)
  end

  def uncategorized_content_api_urls
    @uncategorized_content_api_urls ||= begin
      categorized_api_urls = lists.map(&:contents).flatten.map(&:api_url)
      sector.all_content_api_urls - categorized_api_urls
    end
  end
  helper_method :uncategorized_content_api_urls
end
