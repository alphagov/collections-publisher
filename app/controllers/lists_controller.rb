class ListsController < ApplicationController
  expose(:sector)
  expose(:lists, ancestor: :sector)
  expose(:list, attributes: :list_params)

  def index; end

  def create
    list.sector_id = sector.slug
    list.index = (sector.lists.maximum(:index) || 0) + 1

    if list.save
      flash[:notice] = 'List created'
    else
      flash[:error] = 'Could not create your list'
    end

    redirect_to sector_lists_path(sector)
  end

  def destroy
    list.destroy

    if list.destroyed?
      flash[:notice] = "List deleted"
    else
      flash[:alert] = "Could not delete the list"
    end

    redirect_to sector_lists_path(sector)
  end

  def update
    respond_to do |format|
      format.js {
        if list.save
          render json: {errors: []}
        else
          render json: {errors: list.errors.to_json}, status: 422
        end
      }
    end
  end

private

  def list_params
    params.require(:list).permit(:name, :index)
  end

  def uncategorized_content_api_urls
    @uncategorized_content_api_urls ||= begin
      categorized_api_urls = lists.map(&:contents).flatten.map(&:api_url)
      sector.all_content_api_urls - categorized_api_urls
    end
  end
  helper_method :uncategorized_content_api_urls
end
