class InternalChangeNote < ApplicationRecord
  validates :author, :description, :created_at, presence: true
  belongs_to :step_by_step_page
end
