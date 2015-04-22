class ListsController < ApplicationController
  before_filter :find_topic

  expose(:sector)
  expose(:list, attributes: :list_params)

  def index
    @lists = @topic.lists.ordered
  end

  def edit; end

  def create
    list.topic = @topic
    list.sector_id = sector.slug
    list.index = (sector.lists.maximum(:index) || 0) + 1

    if list.save
      flash[:success] = 'List created'
    else
      flash[:error] = 'Could not create your list'
    end

    redirect_to sector_lists_path(sector)
  end

  def destroy
    list.destroy

    if list.destroyed?
      flash[:success] = "List deleted"
    else
      flash[:alert] = "Could not delete the list"
    end

    redirect_to sector_lists_path(sector)
  end

  def update
    list.dirty = true

    respond_to do |format|
      format.html {
        if list.save
          flash[:success] = 'List updated'
        else
          flash[:error] = 'Could not save your list'
        end

        redirect_to sector_lists_path(sector)
      }
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

  # FIXME: clean this up when we're using content_ids in the URL.
  def find_topic
    if params[:sector_id].include?('/')
      parent_slug, child_slug = params[:sector_id].split('/', 2)
      parent = Topic.find_by!(:slug => parent_slug)
      @topic = parent.children.find_by!(:slug => child_slug)
    else
      @topic = Topic.only_parents.find_by!(:slug => params[:sector_id])
    end
  end

  def list_params
    params.require(:list).permit(:name, :index)
  end
end
