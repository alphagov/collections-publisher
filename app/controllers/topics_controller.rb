class TopicsController < ApplicationController
  include TagCreateUpdatePublish
  tag_create_update_publish_for Topic

  before_filter :require_gds_editor_permissions!

private
  def presenter_klass
    TopicPresenter
  end
end
