class Redirect < ActiveRecord::Base
  self.table_name = 'newest_redirects'

  belongs_to :tag
  has_many :redirect_routes

  before_save :ensure_content_id_is_present

private

  def ensure_content_id_is_present
    self.content_id ||= SecureRandom.uuid
  end
end
