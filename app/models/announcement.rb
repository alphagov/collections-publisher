class Announcement < ApplicationRecord
  belongs_to :coronavirus_page
  validates :text, :href, :published_at, presence: true
  validates :coronavirus_page, presence: true
end
