class InternalChangeNote < ApplicationRecord
  validates :author, :description, :created_at, presence: true
  belongs_to :step_by_step_page

  def readable_created_date
    created_at.strftime('%A, %d %B %Y at %H:%M %p')
  end
end
