# == Schema Information
#
# Table name: list_items
#
#  id         :integer          not null, primary key
#  api_url    :string(255)
#  index      :integer          default(0), not null
#  list_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  title      :string(255)
#
# Indexes
#
#  index_list_items_on_list_id_and_index  (list_id,index)
#

class ListItem < ActiveRecord::Base
  belongs_to :list

  validates :index, numericality: {greater_than_or_equal_to: 0}

  def api_path
    URI(api_url).path
  end
end
