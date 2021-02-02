class Coronavirus::LiveStream < ApplicationRecord
  validates :url, youtube_url: true, presence: true
end
