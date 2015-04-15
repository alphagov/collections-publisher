# == Schema Information
#
# Table name: contents
#
#  id         :integer          not null, primary key
#  api_url    :string(255)
#  index      :integer          default(0), not null
#  list_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  title      :string(255)
#

class Content < ActiveRecord::Base
  belongs_to :list

  validates :index, numericality: {greater_than_or_equal_to: 0}
end
