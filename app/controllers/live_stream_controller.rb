class LiveStreamController < ApplicationController
  before_action :require_livestream_editor_permissions!
  layout "admin_layout"

  def index
    @live_stream = updater.object
  end

  def update
    @live_stream = LiveStream.last
    if @live_stream.update(url: url_params, formatted_stream_date: formatted_date)
      if updater.update
        flash[:notice] = "Draft live stream url updated!"
      else
        flash[:alert] = "Live stream url has not been updated - please try again"
      end
    else
      flash[:alert] = @live_stream.errors.full_messages.join(", ")
    end
    redirect_to live_stream_index_path
  end

  def publish
    if updater.publish
      flash[:notice] = "New live stream url published!"
    else
      flash[:alert] = "Live stream url has not been published - please try again"
    end
    redirect_to live_stream_index_path
  end

private

  def updater
    LiveStreamUpdater.new
  end

  def url_params
    params[:url]
  end

  def formatted_date
    Time.zone.now.strftime("%-d %B %Y")
  end
end
