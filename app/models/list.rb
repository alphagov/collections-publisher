class List < ApplicationRecord
  has_many :list_items, dependent: :destroy
  belongs_to :tag

  scope :ordered, -> { order(:index) }

  validates :tag, presence: true
  validates :name, presence: { message: "Enter a name" }

  def tagged_list_items
    @tagged_list_items ||= list_items_with_tagging_status.select(&:tagged?)
  end

  def list_items_with_tagging_status
    @list_items_with_tagging_status ||= list_items.order(:index).map do |list_item|
      list_item.tagged = tagged_content_ids.include?(list_item.content_id)
      list_item
    end
  end

  def available_list_items
    tag
    .tagged_documents
    .documents
    .reject do |link|
      list_items
      .map(&:content_id)
      .include?(link["content_id"])
    end
  end

private

  def tagged_content_ids
    @tagged_content_ids ||= tag.tagged_documents.map(&:content_id)
  end
end
