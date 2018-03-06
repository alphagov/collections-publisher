class StepByStepPage < ApplicationRecord
  has_many :steps, -> { order(position: :asc) }, dependent: :destroy

  validates :title, :slug, :introduction, :description, presence: true
  validates :slug, format: { with: /\A([a-z0-9]+-)*[a-z0-9]+\z/ }
  validates :slug, uniqueness: true

  include ActiveModel::Validations
  validates_with SlugValidator

  before_validation :generate_content_id, on: :create

private

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
