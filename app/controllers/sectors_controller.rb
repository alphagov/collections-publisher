class SectorsController < ApplicationController
  before_filter :find_topic, :only => [:publish]

  def index
    subtopics = Topic.only_children.includes(:parent).order(:title)
    @grouped_topics = subtopics.group_by(&:parent).sort_by {|parent, _| parent.title }
  end

  def publish
    PublishingAPINotifier.send_to_publishing_api(@topic)

    flash[:success] = "Topic published"
    redirect_to sector_lists_path(@topic)
  end
end
