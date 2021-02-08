class Coronavirus::LiveStream < ApplicationRecord
  self.table_name = "coronavirus_live_streams"

  validates :url, youtube_url: true, presence: true
end
