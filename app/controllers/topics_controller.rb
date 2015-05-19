class TopicsController < ApplicationController
  before_filter :require_gds_editor_permissions!, except: %i[index show republish]

  def index
    @topics = Topic.sorted_parents
  end

  def show
    @topic = find_topic
  end

  def edit
    @topic = find_topic
  end

  def update
    topic = find_topic

    if topic.update_attributes(topic_params)
      PanopticonNotifier.update_tag(TopicPresenter.new(topic))
      PublishingAPINotifier.send_to_publishing_api(topic)
      redirect_to topic
    else
      @topic = topic
      render 'edit'
    end
  end

  def new
    @topic = Topic.new(parent_id: params[:parent_id])
  end

  def create
    topic = Topic.new
    topic.attributes = topic_params

    if topic.save
      PanopticonNotifier.create_tag(TopicPresenter.new(topic))
      PublishingAPINotifier.send_to_publishing_api(topic)
      redirect_to topic
    else
      @topic = topic
      render :new
    end
  end

  def publish
    topic = find_topic

    topic.publish!
    PanopticonNotifier.publish_tag(TopicPresenter.new(topic))
    PublishingAPINotifier.send_to_publishing_api(topic)
    redirect_to topic
  end

  def republish
    topic = find_topic

    PublishingAPINotifier.send_to_publishing_api(topic)
    redirect_to topic_lists_path(topic)
  end

private

  def topic_params
    params.require(:topic).permit(:slug, :title, :description, :parent_id)
  end

  def find_topic
    @_topic ||= Topic.find_by!(content_id: params[:id])
  end
end
