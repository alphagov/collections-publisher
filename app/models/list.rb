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
      list_item.tagged = tagged_base_paths.include?(list_item.base_path)
      list_item
    end
  end

  def available_list_items
    list_items_tagged_to_this_tag =
      tag
      .tagged_documents
      .documents
      .reject do |link|
        list_items
        .map(&:base_path)
        .include?(link["base_path"])
      end
    # browse/benefits
    if tag.parent.content_id == "f141fa95-0d79-4aed-8429-ed223a8f106a"
      subtopics = Tag.find_by(content_id: "4505d908-89f2-4322-956b-29ac243c608b").children
      list_items_tagged_to_mapped_equivalent =
        # topic/benefits-credits
        subtopics.map do |child|
          child.tagged_documents
               .documents
               .reject do |link|
            list_items
           .map(&:base_path)
           .include?(link["base_path"])
          end
        end
      (list_items_tagged_to_this_tag + list_items_tagged_to_mapped_equivalent).flatten
    else
      list_items_tagged_to_this_tag
    end
  end

private

  def tagged_base_paths
    @tagged_base_paths ||= tag.tagged_documents.map(&:base_path)
  end
end
