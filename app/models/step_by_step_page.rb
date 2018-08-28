class StepByStepPage < ApplicationRecord
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

  # Create a deterministic, but unique token that will be used to give one-time
  # access to a piece of draft content.
  # This token is created by using an id that should be unique so that there is
  # little chance of the same token being created to view another piece of content.
  # The code to create the token has been "borrowed" from SecureRandom.uuid,
  # See: http://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html#uuid-method
  def auth_bypass_id
    @_auth_bypass_id ||= begin
      ary = Digest::SHA256.hexdigest(content_id.to_s).unpack('NnnnnN')
      ary[2] = (ary[2] & 0x0fff) | 0x4000
      ary[3] = (ary[3] & 0x3fff) | 0x8000
      "%08x-%04x-%04x-%04x-%04x%08x" % ary
    end
  end

  def links_last_checked_date
    date = steps.map(&:links_last_checked_date).reject(&:blank?).max
    date.strftime('%A, %d %B %Y at %H:%M %p') if date
  end

private

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
