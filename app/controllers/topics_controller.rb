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
      PanopticonNotifier.update_tag(TopicPresenter.new(topic))
      PublishingAPINotifier.send_to_publishing_api(topic)
      RummagerNotifier.new(topic).notify
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

  # Change the topic from draft to published state
  def publish
    topic = find_topic
    TagPublisher.new(topic).publish
    redirect_to topic
  end

  def propose_archive
    @archival = ArchivalForm.new(tag: find_topic)
  end

  def archive
    topic = find_topic

    if topic.published?
      successor = Topic.find(params[:archival_form][:successor])
      TagArchiver.new(topic, successor).archive
      redirect_to topic_path(topic), notice: 'The topic has been archived.'
    else
      DraftTagRemover.new(topic).remove
      redirect_to topics_path, notice: 'The topic has been removed.'
    end
  end

private

  def topic_params
    params.require(:topic).permit(:slug, :title, :description, :parent_id, :beta)
  end

  def find_topic
    @_topic ||= Topic.find_by!(content_id: params[:id])
  end

  def protect_archived_tags!
    topic = find_topic
    if topic.archived?
      flash[:error] = 'You cannot modify an archived topic.'
      redirect_to topic
    end
  end
end
