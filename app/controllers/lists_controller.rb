class ListsController < ApplicationController
  before_action :find_tag
  before_action :require_gds_editor_permissions_to_edit_browse_pages!

  def index
    @lists = @tag.lists.ordered
    render "start_curating_lists" unless @lists.any?
  end

  def edit
    @list = @tag.lists.find(params[:id])
  end

  def create
    list = @tag.lists.build(list_params)
    list.index = (@tag.lists.maximum(:index) || 0) + 1

    if list.save
      @tag.mark_as_dirty!
      flash[:success] = "List created"
    else
      flash[:danger] = "Could not create your list"
    end

    redirect_to tag_lists_path(@tag)
  end

  def destroy
    list = @tag.lists.find(params[:id])
    list.destroy

    if list.destroyed?
      @tag.mark_as_dirty!
      flash[:success] = "List deleted"
    else
      flash[:danger] = "Could not delete the list"
    end

    redirect_to tag_lists_path(@tag)
  end

  def update
    list = @tag.lists.find(params[:id])
    saved = list.update(list_params)

    @tag.mark_as_dirty! if saved

    respond_to do |format|
      format.html {
        if saved
          flash[:success] = "List updated"
        else
          flash[:danger] = "Could not save your list"
        end

        redirect_to tag_lists_path(@tag)
      }
      format.js {
        if saved
          render json: { errors: [] }
        else
          render json: { errors: list.errors.to_json }, status: :unprocessable_entity
        end
      }
    end
  end

private

  def list_params
    params.require(:list).permit(:name, :index)
  end

  def active_navigation_item
    @tag.is_a?(MainstreamBrowsePage) ? "mainstream_browse_pages" : "topics"
  end
end
