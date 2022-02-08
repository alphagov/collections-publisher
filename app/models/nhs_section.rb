class NhsSection < ApplicationRecord
  validates :heading, length: { maximum: 255 }
end
