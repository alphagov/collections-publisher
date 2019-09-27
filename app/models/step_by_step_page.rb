class StepByStepPage < ApplicationRecord
  STATUSES = %w(
    approved_2i
    draft
    in_review
    published
    scheduled
    submitted_for_2i
  ).freeze

  has_many :navigation_rules, -> { order(title: :asc) }, dependent: :destroy
  has_many :steps, -> { order(position: :asc) }, dependent: :destroy
  has_many :internal_change_notes, -> { order(created_at: :desc) }
  has_many :secondary_content_links, -> { order(title: :asc) }, dependent: :destroy

  belongs_to :reviewer, primary_key: "uid", class_name: "User", optional: true
  belongs_to :review_requester, primary_key: "uid", class_name: "User", optional: true

  validates :title, :slug, :introduction, :description, presence: true
  validates :scheduled_at, in_future: true
  validates :slug, format: { with: /\A([a-z0-9]+-)*[a-z0-9]+\z/ }, uniqueness: true
  validates :slug, slug: true, on: :create
  validates :status, inclusion: { in: STATUSES }, presence: true
  validates :status, status_prerequisite: true
  validate :reviewer_is_not_same_as_review_requester

  before_validation :generate_content_id, on: :create
  before_destroy :discard_notes

  scope :by_title, -> { order(:title) }

  def has_been_published?
    published_at.present?
  end

  def has_draft?
    draft_updated_at.present? && draft_updated_at != published_at
  end

  def scheduled_for_publishing?
    status.scheduled?
  end

  def mark_draft_updated
    update(
      draft_updated_at: Time.zone.now,
      status: "draft",
    )
  end

  def mark_draft_deleted
    update_attribute(:draft_updated_at, nil)
  end

  def mark_as_published
    now = Time.zone.now
    update(
      published_at: now,
      draft_updated_at: now,
      scheduled_at: nil,
      assigned_to: nil,
      review_requester_id: nil,
      reviewer_id: nil,
      status: "published",
    )
  end

  def mark_as_unpublished
    update(
      published_at: nil,
      draft_updated_at: nil,
      status: "draft",
    )
  end

  def mark_as_scheduled
    update_attribute(:status, "scheduled")
  end

  def mark_as_unscheduled
    update_attribute(:status, "draft")
  end

  def self.validate_redirect(redirect_url)
    regex = /\A\/([a-z0-9]+-)*[a-z0-9]+\z/
    redirect_url =~ regex
  end

  def status
    (read_attribute("status") || "").inquiry
  end

  def unpublished_changes?
    has_draft? && has_been_published?
  end

  def can_be_published?
    has_draft? &&
      !scheduled_for_publishing? &&
      steps_have_content? &&
      links_checked_since_last_update? &&
      !broken_links_found?
  end

  def can_be_unpublished?
    has_been_published? && !scheduled_for_publishing?
  end

  def can_discard_changes?
    unpublished_changes? && !scheduled_for_publishing?
  end

  def can_be_deleted?
    !has_been_published? && !scheduled_for_publishing?
  end

  def can_be_edited?
    !scheduled_for_publishing?
  end

  def steps_have_content?
    steps.any? && steps.map(&:contents).all?(&:present?)
  end

  # Create a deterministic, but unique token that will be used to give one-time
  # access to a piece of draft content.
  # This token is created by using an id that should be unique so that there is
  # little chance of the same token being created to view another piece of content.
  # The code to create the token has been "borrowed" from SecureRandom.uuid,
  # See: http://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html#uuid-method
  def auth_bypass_id
    @auth_bypass_id ||= begin
      ary = Digest::SHA256.hexdigest(content_id.to_s).unpack("NnnnnN")
      ary[2] = (ary[2] & 0x0fff) | 0x4000
      ary[3] = (ary[3] & 0x3fff) | 0x8000
      "%08x-%04x-%04x-%04x-%04x%08x" % ary
    end
  end

  def links_last_checked_date
    steps.map(&:links_last_checked_date).reject(&:blank?).max
  end

  def should_show_required_prepublish_actions?
    has_draft? && !scheduled_for_publishing? && !can_be_published?
  end

  def broken_links_found?
    steps.any?(&:broken_links?)
  end

  def links_checked_since_last_update?
    links_checked? && links_last_checked_date > draft_updated_at
  end

  def links_checked?
    steps.map(&:link_report?).any?
  end

  def discard_notes
    internal_change_notes.where(edition_number: nil).delete_all
  end

private

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end

  def reviewer_is_not_same_as_review_requester
    if review_requester_id.present? && review_requester_id == reviewer_id
      errors.add(:reviewer_id, "can't be the same as review_requester_id")
    end
  end
end
