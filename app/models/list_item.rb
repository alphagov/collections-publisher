# == Schema Information
#
# Table name: list_items
#
#  id         :integer          not null, primary key
#  base_path  :string(255)
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

  attr_accessor :tagged
  alias :tagged? :tagged

  # FIXME: remove these once everything has been migrated to use base_path
  def api_url
    return nil if self.base_path.nil?
    Plek.find('contentapi') + api_path
  end
  def api_url=(value)
    self.base_path = URI.parse(value).path.chomp('.json')
  end

  def api_path
    base_path + '.json'
  end
end
