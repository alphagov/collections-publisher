# == Schema Information
#
# Table name: lists
#
#  id     :integer          not null, primary key
#  name   :string(255)
#  index  :integer          default(0), not null
#  tag_id :integer          not null
#
# Indexes
#
#  index_lists_on_tag_id  (tag_id)
#

class List < ActiveRecord::Base
  has_many :list_items, dependent: :destroy
  belongs_to :tag

  scope :ordered, -> { order(:index) }

  validates :tag, :presence => true

  def tagged_list_items
    @tagged_list_items ||= list_items.order(:index).select {|c| tagged_api_paths.include?(c.api_path) }
  end

  def untagged_list_items
    @tagged_list_items ||= list_items - tagged_list_items
  end

private

  def tagged_api_paths
    @tagged_api_paths ||= tag.list_items_from_contentapi.map(&:api_path)
  end
end
