class InternalChangeNote < ApplicationRecord
  validates :author, :headline, presence: true
  belongs_to :step_by_step_page

  def readable_created_date
    created_at.strftime("%A, %d %B %Y at %I:%M %p")
  end
end
