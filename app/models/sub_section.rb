class SubSection < ApplicationRecord
  belongs_to :coronavirus_page
  validates :title, :content, presence: true
end
