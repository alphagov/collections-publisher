class ListItemsController < ApplicationController
  layout :get_layout
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
          flash[:notice] = "Content added"
        else
          flash[:alert] = "Could not add that list item to your list"
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

    if redesigned_lists_permission?
      ListPublisher.new(@tag).perform
      flash[:success] = "Content removed from list"

      redirect_to tag_list_path(@tag, @list)
    else
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
            render json: { errors: list_item.errors }, status: :unprocessable_entity
          end
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

  def confirm_destroy
    @list_item = @list.list_items.find(params[:id])
  end

private

  def get_layout
    if redesigned_lists_permission? && action_name.in?(%w[confirm_destroy])
      "design_system"
    else
      "legacy"
    end
  end

  def find_list
    @list = @tag.lists.find(params[:list_id])
  end

  def list_item_params
    params.require(:list_item).permit(:title, :base_path, :index)
  end
end
