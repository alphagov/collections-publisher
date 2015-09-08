class ArchivalForm
  include ActiveModel::Model
  attr_accessor :tag, :successor

  def topics
    published_topics - [tag]
  end

private

  def published_topics
    Topic.includes(:parent).published.sort_by(&:title_including_parent)
  end
end
