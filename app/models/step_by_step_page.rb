class StepByStepPage < ApplicationRecord
  has_many :steps, -> { order(position: :asc) }, dependent: :destroy

  validates :title, :slug, :introduction, :description, presence: true
  validates :slug, format: { with: /\A([a-z0-9]+-)*[a-z0-9]+\z/ }, uniqueness: true
  validates :slug, slug: true, on: :create
  before_validation :generate_content_id, on: :create

  def self.validate_redirect(redirect_url)
    regex = /\A([a-z0-9]+-)*[a-z0-9]+\z/
    redirect_url =~ regex
  end

private

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end
end
