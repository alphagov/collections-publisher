class ArchivalForm
  include ActiveModel::Model
  attr_accessor :tag, :successor, :successor_path

  validates :successor_path, presence: true, valid_govuk_path: true, if: :redirecting_to_path?

  def topics
    published_topics - [tag]
  end

  def archive_or_remove
    return false unless valid?

    if tag.published?
      TagArchiver.new(tag, successor_object).archive
    else
      DraftTagRemover.new(tag).remove
    end

    true
  rescue GdsApi::HTTPConflict
    errors.add :base, "The tag could not be deleted because there are documents tagged to it."
    false
  rescue GdsApi::HTTPClientError
    errors.add :base, "The tag could not be deleted because of an error."
    false
  end

private

  def successor_object
    if redirecting_to_path?
      OpenStruct.new(base_path: successor_path, subroutes: [])
    else
      Topic.find_by_id(successor)
    end
  end

  def published_topics
    Topic.includes(:parent).published.sort_by(&:title_including_parent)
  end

  def redirecting_to_path?
    !successor_path.nil?
  end
end
