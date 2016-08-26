class ListItem < ActiveRecord::Base
  belongs_to :list

  validates :index, numericality: { greater_than_or_equal_to: 0 }

  attr_accessor :tagged
  alias :tagged? :tagged

  def display_title
    list.tag.tagged_document_for_base_path(base_path).try(:title) || title
  end

  def content_id
    list.tag.tagged_document_for_base_path(base_path).content_id
  end
end
