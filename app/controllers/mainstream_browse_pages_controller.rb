class MainstreamBrowsePagesController < ApplicationController
  include TagCreateUpdatePublish
  tag_create_update_publish_for MainstreamBrowsePage

  before_filter :require_gds_editor_permissions!

  def edit
    @topics = Topic.all
  end

  def show; end

  def update
    # Convert the String ids to Topic objects so that
    # `update_attributes` correct updates and associates
    # them with the given `MainstreamBrowsePage` object.
    if params.require(:mainstream_browse_page).key? :topics
      topic_ids = params.require(:mainstream_browse_page)[:topics]
      topics = topic_ids.reject(&:blank?).map { |t| Topic.find(t) }
      msb_params = tag_params.merge({"topics" => topics})
    else
      msb_params = tag_params
    end

    if @resource.update_attributes(msb_params)
      PanopticonNotifier.update_tag(
        presenter_klass.new(@resource)
      )
      if @resource.published?
        PublishingAPINotifier.send_to_publishing_api(@resource)
      end

      redirect_to mainstream_browse_page_path(@resource)
    else
      @topics = Topic.all
      render :edit
    end
  end

private
  def presenter_klass
    MainstreamBrowsePagePresenter
  end
end
