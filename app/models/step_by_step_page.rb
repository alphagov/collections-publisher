class StepByStepPage < ApplicationRecord
  STATUSES = %w(
    draft
    submitted_for_2i
    in_review
    approved_2i
    scheduled
    published
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

  before_validation :strip_slug_spaces
  before_destroy :discard_notes

  scope :by_title, -> { order(:title) }

  attribute :content_id, :string, default: -> { SecureRandom.uuid }
  attribute :auth_bypass_id, :string, default: -> { SecureRandom.uuid }

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

  def mark_as_approved_2i
    update_attribute(:status, "approved_2i")
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
      draft_updated_at: Time.zone.now,
      status: "approved_2i",
    )
  end

  def mark_as_scheduled
    update_attribute(:status, "scheduled")
  end

  def mark_as_unscheduled
    update_attribute(:status, "approved_2i")
  end

  def refresh_auth_bypass_id
    update_attribute(:auth_bypass_id, SecureRandom.uuid)
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
      status.approved_2i?
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

  def links_last_checked_date
    steps.map(&:links_last_checked_date).reject(&:blank?).max
  end

  def should_show_required_prepublish_actions?
    (has_draft? && !scheduled_for_publishing? && !can_be_published?) || status.in_review?
  end

  def links_checked_since_last_update?
    (links_checked? && links_last_checked_date > draft_updated_at) || status.approved_2i?
  end

  def links_checked?
    steps.map(&:link_report?).any?
  end

  def discard_notes
    internal_change_notes.where(edition_number: nil).delete_all
  end

  def make_step_positions_sequential
    steps.sort_by(&:position).each.with_index(1) do |step, index|
      step.update_attributes!(position: index)
    end
  end

private

  def strip_slug_spaces
    self.slug.gsub!(/^\s+|\s+$/, "")
  end

  def reviewer_is_not_same_as_review_requester
    if review_requester_id.present? && review_requester_id == reviewer_id
      errors.add(:reviewer_id, "can't be the same as review_requester_id")
    end
  end
end
