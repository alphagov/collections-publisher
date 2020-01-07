class List < ApplicationRecord
  has_many :list_items, dependent: :destroy
  belongs_to :tag

  scope :ordered, -> { order(:index) }

  validates :tag, presence: true

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
    @tagged_base_paths ||= tag.tagged_documents.map(&:base_path)
  end
end
