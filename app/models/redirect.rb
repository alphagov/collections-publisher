class Redirect < ActiveRecord::Base
  self.table_name = 'newest_redirects'

  belongs_to :tag
  has_many :redirect_routes
end
