class MainstreamBrowsePageArchivalForm
  include ActiveModel::Model
  REDIRECT_TYPES = %w[browse_page path].freeze

  attr_accessor :tag, :successor, :successor_path, :redirect_type

  validate :tag_can_be_archived_or_removed

  with_options unless: :removing_draft? do
    validates :redirect_type, inclusion: { in: REDIRECT_TYPES, message: "Select where the page should redirect to" }
    validate :successor_is_a_published_browse_page, if: :redirecting_to_browse_page?
    validates :successor_path, presence: { message: "Enter a page URL path" }, if: :redirecting_to_path?
    validates :successor_path, valid_govuk_path: true, allow_blank: true, if: :redirecting_to_path?
  end

  def browse_pages
    published_browse_pages - [tag]
  end

  def grouped_browse_pages
    browse_pages.group_by { |page| page.parent || page }.map do |top_level_page, pages|
      [top_level_page.title, pages.map { |page| { text: page.title, value: page.id, selected: page.id.to_s == successor.to_s } }]
    end
  end

  def successor_browse_page
    browse_pages.find { |page| page.id.to_s == successor.to_s }
  end

  def redirecting_to_path?
    redirect_type == "path"
  end

  def redirecting_to_browse_page?
    redirect_type == "browse_page"
  end

  # Draft pages are deleted rather than redirected, so don't need a successor
  def removing_draft?
    tag.present? && tag.draft?
  end

  def archive_or_remove
    return false unless valid?

    if tag.published?
      TagArchiver.new(tag, successor_object).archive
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
    if redirecting_to_path?
      ContentItem.find!(successor_path)
    else
      successor_browse_page
    end
  end

  def published_browse_pages
    MainstreamBrowsePage.includes(:parent).published.sort_by(&:title_including_parent)
  end

  def tag_can_be_archived_or_removed
    return if tag.blank? || tag.can_be_archived? || tag.can_be_removed?

    errors.add :base, "This mainstream browse page cannot be archived or removed"
  end

  def successor_is_a_published_browse_page
    errors.add :successor, "Select a mainstream browse page" if successor_browse_page.nil?
  end
end
