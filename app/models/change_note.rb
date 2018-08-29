class ChangeNote < ApplicationRecord
  validates :author, :description, :created_at
  belongs_to :step_by_step_page
end
