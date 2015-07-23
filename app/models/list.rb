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
    @tagged_list_items ||= list_items_with_tagging_status.select(&:tagged?)
  end

  def list_items_with_tagging_status
    @list_items_with_tagging_status ||= begin
      list_items.order(:index).map do |list_item|
        list_item.tagged = tagged_base_paths.include?(list_item.base_path)
        list_item
      end
    end
  end

private

  def tagged_base_paths
    @tagged_base_paths ||= tag.list_items_from_contentapi.map(&:base_path)
  end
end
