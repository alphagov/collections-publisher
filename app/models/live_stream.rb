class LiveStream < ApplicationRecord
  validates :url, url: true, presence: true
end
