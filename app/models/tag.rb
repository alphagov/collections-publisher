require 'securerandom'

class Tag < ActiveRecord::Base
  belongs_to :parent, class_name: 'Tag'
  has_many :children, class_name: 'Tag', foreign_key: :parent_id

  validates :slug, :title, :content_id, presence: true
  validates :slug, uniqueness: { scope: :parent_id }
  validate :parent_is_not_a_child

  before_validation :generate_content_id, on: :create

  scope :only_parents, -> { where('parent_id IS NULL') }

  def can_have_children?
    parent_id.blank?
  end

private
  def parent_is_not_a_child
    if parent.present? && parent.parent_id.present?
      errors.add(:parent, 'is a child tag')
    end
  end

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
