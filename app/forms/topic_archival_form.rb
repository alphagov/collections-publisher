class TopicArchivalForm
  include ActiveModel::Model
  attr_accessor :tag, :successor, :successor_path, :email_migration_path

  validates :successor_path, presence: true, valid_govuk_path: true
  validates :email_migration_path, valid_govuk_path: true, if: :email_migration_path_provided?

  def archive_or_remove
    if tag.published?
      return false unless valid?

      TagArchiver.new(tag, successor_object, email_migration_path).archive
    else
      DraftTagRemover.new(tag).remove
    end

    true
  rescue GdsApi::HTTPClientError
    errors.add :base, "The tag could not be deleted because of an error."
    false
  end

private

  def successor_object
    Struct.new("RedirectToPath", :base_path, :subroutes)
    Struct::RedirectToPath.new(successor_path, [])
  end

  def email_migration_path_provided?
    email_migration_path.present?
  end

  def published_topics
    Topic.includes(:parent).published.sort_by(&:title_including_parent)
  end
end
