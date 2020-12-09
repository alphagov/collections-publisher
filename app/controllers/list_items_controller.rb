class ListItemsController < ApplicationController
  before_action :find_tag
  before_action :find_list
  before_action :require_gds_editor_permissions_to_edit_browse_pages!

  def create
    list_item = @list.list_items.build(list_item_params)
    saved = list_item.save

    @tag.mark_as_dirty! if saved

    respond_to do |format|
      format.html do
        if saved
          flash[:success] = "Content added"
        else
          flash[:danger] = "Could not add that list item to your list"
        end

        redirect_to tag_lists_path(@tag)
      end
      format.js do
        if saved
          render json: { errors: [], updateURL: tag_list_list_item_path(@tag, @list, list_item) }
        else
          render json: { errors: list_item.errors }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    list_item = @list.list_items.find(params[:id])
    list_item.destroy!

    destroyed = list_item.destroyed?

    @tag.mark_as_dirty! if destroyed

    respond_to do |format|
      format.html do
        if destroyed
          flash[:success] = "Content removed from list"
        else
          flash[:danger] = "Could not remove the list item from this list"
        end

        redirect_to tag_lists_path(@tag)
      end
      format.js do
        if destroyed
          render json: { errors: [] }
        else
          render json: { errors: list_item.errors.to_json }, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    list_item = ListItem.find(params[:id])
    list_item.list = List.find(params[:new_list_id])
    list_item.index = params[:index]

    respond_to do |format|
      format.js do
        if list_item.save
          @tag.mark_as_dirty!

          render json: { errors: [] }
        else
          render json: { errors: list_item.errors }, status: :unprocessable_entity
        end
      end
    end
  end

private

  def find_list
    @list = @tag.lists.find(params[:list_id])
  end

  def list_item_params
    params.require(:list_item).permit(:title, :base_path, :index)
  end
end
