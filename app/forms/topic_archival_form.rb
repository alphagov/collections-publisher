class TopicArchivalForm
  include ActiveModel::Model
  attr_accessor :tag, :successor_path

  validates :successor_path, presence: true, valid_govuk_path: true

  def archive_or_remove
    if tag.published?
      return false unless valid?

      TagArchiver.new(tag, successor_object).archive
    else
      DraftTagRemover.new(tag).remove
    end

    true
  rescue EmailAlertApi::SubscriberListUpdater::SuccessorDestinationError => e
    errors.add :base, e.message
    false
  rescue GdsApi::HTTPClientError
    errors.add :base, "The tag could not be deleted because of an error."
    false
  end

private

  def successor_object
    ContentItem.find!(successor_path)
  end

  def published_topics
    Topic.includes(:parent).published.sort_by(&:title_including_parent)
  end
end
