class TopicsController < ApplicationController
  before_filter :require_gds_editor_permissions!, except: %i[index show]
  before_filter :protect_archived_tags!, only: %i[edit update publish]

  def index
    @topics = Topic.sorted_parents
  end

  def show
    @topic = find_topic
    render 'archived_topic' if @topic.archived?
  end

  def edit
    @topic = find_topic
  end

  def update
    topic = find_topic

    if topic.update_attributes(topic_params)
      TagUpdateBroadcaster.broadcast(topic)
      redirect_to topic, success: "Topic updated"
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
      TagCreateBroadcaster.broadcast(topic)
      redirect_to topic
    else
      @topic = topic
      render :new
    end
  end

  # Change the topic from draft to published state
  def publish
    topic = find_topic
    TagPublisher.new(topic).publish
    redirect_to topic
  end

  def propose_archive
    @archival = TopicArchivalForm.new(tag: find_topic)
  end

  def archive
    @archival = TopicArchivalForm.new(params[:topic_archival_form])
    @archival.tag = find_topic

    if @archival.archive_or_remove
      redirect_to topics_path, success: 'The topic has been archived or removed.'
    else
      render 'propose_archive'
    end
  end

private

  def topic_params
    params.require(:topic).permit(:slug, :title, :description, :parent_id)
  end

  def find_topic
    @_topic ||= Topic.find_by!(content_id: params[:id])
  end

  def protect_archived_tags!
    topic = find_topic
    if topic.archived?
      flash[:danger] = 'You cannot modify an archived topic.'
      redirect_to topic
    end
  end
end
