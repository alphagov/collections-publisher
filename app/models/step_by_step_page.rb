class StepByStepPage < ApplicationRecord
  has_many :steps, -> { order(position: :asc) }, dependent: :destroy

  validates :title, :base_path, presence: true
  validates :base_path, format: { with: /\A([a-z0-9]+-)*[a-z0-9]+\z/ }
  validates :base_path, uniqueness: true
end
