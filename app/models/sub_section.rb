class SubSection < ApplicationRecord
  belongs_to :coronavirus_page
  validates :title, :content, presence: true
  validates :coronavirus_page, presence: true
end
