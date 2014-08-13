class ContentsController < ApplicationController
  expose(:sector)
  expose(:list)
  expose(:content, attributes: :content_params)

  def create
    content.list = list

    saved = content.save

    respond_to do |format|
      format.html {
        if saved
          flash[:notice] = 'Content added'
        else
          flash[:error] = 'Could not add that content to your list'
        end

        redirect_to sector_lists_path(sector)
      }
      format.js {
        if saved
          render json: {errors: [], updateURL: sector_list_content_path(sector, list, content)}
        else
          render json: {errors: content.errors.to_json}, status: 422
        end
      }
    end
  end

  def destroy
    content.destroy

    destroyed = content.destroyed?

    respond_to do |format|
      format.html {
        if destroyed
          flash[:notice] = "Content removed from list"
        else
          flash[:alert] = "Could not remove the content from this list"
        end

        redirect_to sector_lists_path(sector)
      }
      format.js {
        if destroyed
          render json: {errors: []}
        else
          render json: {errors: content.errors.to_json}, status: 422
        end
      }
    end
  end

  def update
    content.list = List.find(params[:new_list_id])
    content.index = params[:index]

    respond_to do |format|
      format.js {
        if content.save
          render json: {errors: []}
        else
          render json: {errors: content.errors.to_json}, status: 422
        end
      }
    end
  end

private

  def content_params
    params.require(:content).permit(:api_url, :index)
  end
end
