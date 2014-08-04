class ContentsController < ApplicationController
  expose(:sector)
  expose(:list)
  expose(:content, attributes: :content_params)

  def create
    content.list = list

    if content.save
      flash[:notice] = 'Content added'
    else
      flash[:error] = 'Could not add that content to your list'
    end

    redirect_to sector_lists_path(sector)
  end

private

  def content_params
    params.require(:content).permit(:api_url, :index)
  end
end
