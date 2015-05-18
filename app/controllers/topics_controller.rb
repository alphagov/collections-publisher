class TopicsController < ApplicationController
  include TagCreateUpdatePublish
  tag_create_update_publish_for Topic

  before_filter :require_gds_editor_permissions!, except: %i[index show republish]

  def republish
    topic = Topic.find_by!(content_id: params[:id])
    PublishingAPINotifier.send_to_publishing_api(topic)
    redirect_to topic_lists_path(topic)
  end

private

  def presenter_klass
    TopicPresenter
  end
end
