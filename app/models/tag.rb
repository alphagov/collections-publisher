class Tag < ActiveRecord::Base
  belongs_to :parent, class_name: 'Tag'

  validates :slug, :title, presence: true
  validate :parent_is_not_a_child

private
  def parent_is_not_a_child
    if parent.present? && parent.parent_id.present?
      errors.add(:parent, 'is a child tag')
    end
  end
end
