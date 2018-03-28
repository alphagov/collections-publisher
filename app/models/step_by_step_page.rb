class StepByStepPage < ApplicationRecord
  has_many :navigation_rules, dependent: :destroy
  has_many :steps, -> { order(position: :asc) }, dependent: :destroy

  validates :title, :slug, :introduction, :description, presence: true
  validates :slug, format: { with: /\A([a-z0-9]+-)*[a-z0-9]+\z/ }, uniqueness: true
  validates :slug, slug: true, on: :create
  before_validation :generate_content_id, on: :create

  def has_been_published?
    published_at.present?
  end

  def has_draft?
    draft_updated_at.present?
  end

  def mark_draft_updated
    update_attribute(:draft_updated_at, Time.zone.now)
  end

  def mark_draft_deleted
    update_attribute(:draft_updated_at, nil)
  end

  def mark_as_published
    update_attribute(:published_at, Time.zone.now)
  end

  def mark_as_unpublished
    update_attribute(:published_at, nil)
  end

private

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
