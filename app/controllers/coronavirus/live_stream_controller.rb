module Coronavirus
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
          flash[:notice] = I18n.t("coronavirus.pages.live_stream.update.success")
        else
          flash[:alert] = I18n.t("coronavirus.pages.live_stream.update.failed")
        end
      else
        flash[:alert] = @live_stream.errors.full_messages.join(", ")
      end
      redirect_to coronavirus_live_stream_index_path
    end

    def publish
      if updater.publish
        flash[:notice] = I18n.t("coronavirus.pages.live_stream.publish.success")
      else
        flash[:alert] = I18n.t("coronavirus.pages.live_stream.publish.failed")
      end
      redirect_to coronavirus_live_stream_index_path
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
end
