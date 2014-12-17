class TopicsController < ApplicationController
  include TagCreateUpdatePublish
  tag_create_update_publish_for Topic

private
  def presenter_klass
    TopicPresenter
  end
end
