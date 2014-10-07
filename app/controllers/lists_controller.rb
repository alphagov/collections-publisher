class ListsController < ApplicationController
  expose(:sector)
  expose(:list, attributes: :list_params)

  def index; end

  def edit; end

  def create
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

  def list_params
    params.require(:list).permit(:name, :index)
  end
end
