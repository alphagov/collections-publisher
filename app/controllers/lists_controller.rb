class ListsController < ApplicationController
  before_filter :find_topic_for_sector_id

  def index
    @lists = @topic.lists.ordered
  end

  def edit
    @list = @topic.lists.find(params[:id])
  end

  def create
    list = @topic.lists.build(list_params)
    list.index = (@topic.lists.maximum(:index) || 0) + 1

    if list.save
      @topic.mark_as_dirty!
      flash[:success] = 'List created'
    else
      flash[:error] = 'Could not create your list'
    end

    redirect_to sector_lists_path(@topic.panopticon_slug)
  end

  def destroy
    list = @topic.lists.find(params[:id])
    list.destroy

    if list.destroyed?
      @topic.mark_as_dirty!
      flash[:success] = "List deleted"
    else
      flash[:alert] = "Could not delete the list"
    end

    redirect_to sector_lists_path(@topic.panopticon_slug)
  end

  def update
    list = @topic.lists.find(params[:id])
    saved = list.update_attributes(list_params)

    @topic.mark_as_dirty! if saved

    respond_to do |format|
      format.html {
        if saved
          flash[:success] = 'List updated'
        else
          flash[:error] = 'Could not save your list'
        end

        redirect_to sector_lists_path(@topic.panopticon_slug)
      }
      format.js {
        if saved
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
end
