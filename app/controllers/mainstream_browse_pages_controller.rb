class MainstreamBrowsePagesController < ApplicationController
  include TagCreateUpdatePublish
  tag_create_update_publish_for MainstreamBrowsePage

private
  def presenter_klass
    MainstreamBrowsePagePresenter
  end
end
