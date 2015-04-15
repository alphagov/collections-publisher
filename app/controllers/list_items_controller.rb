class ListItemsController < ApplicationController
  expose(:sector)
  expose(:list)
  expose(:list_item, attributes: :list_item_params)

  def create
    list_item.list = list

    saved = list_item.save

    list_item.list.update_attribute(:dirty, true) if saved

    respond_to do |format|
      format.html {
        if saved
          flash[:success] = 'Content added'
        else
          flash[:error] = 'Could not add that list item to your list'
        end

        redirect_to sector_lists_path(sector)
      }
      format.js {
        if saved
          render json: {errors: [], updateURL: sector_list_list_item_path(sector, list, list_item)}
        else
          render json: {errors: list_item.errors.to_json}, status: 422
        end
      }
    end
  end

  def destroy
    list_item.destroy

    destroyed = list_item.destroyed?

    list_item.list.update_attribute(:dirty, true) if destroyed

    respond_to do |format|
      format.html {
        if destroyed
          flash[:success] = "Content removed from list"
        else
          flash[:alert] = "Could not remove the list item from this list"
        end

        redirect_to sector_lists_path(sector)
      }
      format.js {
        if destroyed
          render json: {errors: []}
        else
          render json: {errors: list_item.errors.to_json}, status: 422
        end
      }
    end
  end

  def update
    list_item.list = List.find(params[:new_list_id])
    list_item.index = params[:index]

    respond_to do |format|
      format.js {
        if list_item.save
          list_item.list.update_attribute(:dirty, true)

          render json: {errors: []}
        else
          render json: {errors: list_item.errors.to_json}, status: 422
        end
      }
    end
  end

private

  def list_item_params
    params.require(:list_item).permit(:title, :api_url, :index)
  end
end
