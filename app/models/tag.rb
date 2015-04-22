# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  slug        :string(255)      not null
#  title       :string(255)      not null
#  description :string(255)
#  parent_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#  content_id  :string(255)      not null
#  state       :string(255)      not null
#
# Indexes
#
#  index_tags_on_slug_and_parent_id  (slug,parent_id) UNIQUE
#

require 'securerandom'

class Tag < ActiveRecord::Base
  include AASM
  include ActiveModel::Dirty

  belongs_to :parent, class_name: 'Tag'
  has_many :children, class_name: 'Tag', foreign_key: :parent_id

  validates :slug, :title, :content_id, presence: true
  validates :slug, uniqueness: { scope: ["parent_id"] }, format: { with: /\A[a-z0-9-]*\z/ }
  validate :parent_is_not_a_child
  validate :slug_change_once_published

  before_validation :generate_content_id, on: :create

  scope :only_parents, -> { where('parent_id IS NULL') }
  scope :in_alphabetical_order, -> { order('title ASC') }

  aasm column: :state do
    state :draft, initial: true
    state :published

    event :publish do
      transitions from: :draft, to: :published
    end
  end

  def can_have_children?
    parent_id.blank?
  end

  def draft_children
    children.draft
  end

  def has_parent?
    parent.present?
  end

  def base_path
    base = has_parent? ? "/#{parent.slug}" : ''
    "#{base}/#{slug}"
  end

  def to_param
    content_id
  end

private
  # The state for a Tag can only be set using the event methods declared in the
  # `aasm` block above. As we don't want to allow the state to be set using the
  # ActiveRecord-provided setter method, override it here to make it private.
  def state=(*args)
    super(*args)
  end

  def parent_is_not_a_child
    if parent.present? && parent.parent_id.present?
      errors.add(:parent, 'is a child tag')
    end
  end

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end

  def slug_change_once_published
    if slug_changed? && state == 'published'
      errors.add(:slug, 'cannot change a slug once published')
    end
  end
end
