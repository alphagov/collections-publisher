class StepByStepPage < ApplicationRecord
  include JwtHelper

  has_many :navigation_rules, -> { order(title: :asc) }, dependent: :destroy
  has_many :steps, -> { order(position: :asc) }, dependent: :destroy

  validates :title, :slug, :introduction, :description, presence: true
  validates :slug, format: { with: /\A([a-z0-9]+-)*[a-z0-9]+\z/ }, uniqueness: true
  validates :slug, slug: true, on: :create
  before_validation :generate_content_id, on: :create

  scope :by_title, -> { order(:title) }

  def has_been_published?
    published_at.present?
  end

  def has_draft?
    draft_updated_at.present? && draft_updated_at != published_at
  end

  def mark_draft_updated
    update_attribute(:draft_updated_at, Time.zone.now)
  end

  def mark_draft_deleted
    update_attribute(:draft_updated_at, nil)
  end

  def mark_as_published
    now = Time.zone.now
    update_attribute(:published_at, now)
    update_attribute(:draft_updated_at, now)
  end

  def mark_as_unpublished
    update_attribute(:published_at, nil)
    update_attribute(:draft_updated_at, nil)
  end

  def self.validate_redirect(redirect_url)
    regex = /\A\/([a-z0-9]+-)*[a-z0-9]+\z/
    redirect_url =~ regex
  end

  def auth_bypass_id
    @_auth_bypass_id ||= auth_bypass_token(content_id)
  end

private

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
