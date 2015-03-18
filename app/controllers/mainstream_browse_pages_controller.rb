class MainstreamBrowsePagesController < ApplicationController
  include TagCreateUpdatePublish
  tag_create_update_publish_for MainstreamBrowsePage

  before_filter :require_gds_editor_permissions!

private
  def presenter_klass
    MainstreamBrowsePagePresenter
  end
end
