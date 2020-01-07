require "securerandom"

class Tag < ApplicationRecord
  include AASM
  include ActiveModel::Dirty
  ORDERING_TYPES = %w(alphabetical curated).freeze

  belongs_to :parent, class_name: "Tag"
  has_many :children, class_name: "Tag", foreign_key: :parent_id

  has_many :tag_associations, foreign_key: :from_tag_id
  has_many :reverse_tag_associations, foreign_key: :to_tag_id,
           class_name: "TagAssociation"

  has_many :lists
  has_many :list_items, through: :lists
  has_many :redirect_routes

  validates :slug, :title, :content_id, presence: true
  validates :slug, uniqueness: { scope: %w(parent_id) }, format: { with: /\A[a-z0-9-]*\z/ }
  validates :child_ordering, inclusion: { in: ORDERING_TYPES }
  validate :parent_is_not_a_child
  validate :cannot_change_slug

  before_validation :generate_content_id, on: :create

  scope :only_parents, -> { where("parent_id IS NULL") }
  scope :only_children, -> { where("parent_id IS NOT NULL") }

  # The links last sent to the content-store.
  serialize :published_groups, JSON

  # after_initialize is expensive, but MySQL doesn't support default values
  # on text columns. When we've moved to PG, move this to the database.
  after_initialize do
    self.published_groups ||= []
  end

  aasm column: :state, no_direct_assignment: true do
    state :draft, initial: true
    state :published
    state :archived

    event :move_to_archive do
      transitions from: :published, to: :archived
    end

    event :publish do
      transitions from: :draft, to: :published
    end
  end

  def can_have_children?
    parent_id.blank?
  end

  def draft_children
    children.draft
  end

  def has_parent?
    parent.present?
  end

  alias child? has_parent?
  alias parent? can_have_children?

  def self.sorted_parents
    only_parents.includes(children: [:lists]).order(:title)
  end

  def sorted_children
    if child_ordering == "alphabetical"
      children.sort_by { |child| child.title.downcase }
    else
      children.sort_by(&:index)
    end
  end

  def sorted_children_that_are_not_archived
    sorted_children.reject { |child| child.state == "archived" }
  end

  def title_including_parent
    if has_parent?
      "#{parent.title} / #{title}"
    else
      title
    end
  end

  def to_param
    content_id
  end

  def mark_as_dirty!
    update_columns(dirty: true)
  end

  def web_url
    Plek.new.website_root + base_path
  end

  def uncurated_tagged_documents
    curated_base_paths = list_items.map(&:base_path)
    tagged_documents.reject do |document|
      curated_base_paths.include?(document.base_path)
    end
  end

  def tagged_documents
    @tagged_documents ||= TaggedDocuments.new(self)
  end

  def tagged_document_for_base_path(base_path)
    tagged_documents.find { |document| document.base_path == base_path }
  end

  def sort_mode
    return nil unless parent_id

    display_curated_links? ? :curated : :a_to_z
  end

  def display_curated_links?
    if @_display_curated_links.nil?
      @_display_curated_links = lists.any?
    else
      @_display_curated_links
    end
  end

  def full_slug
    @full_slug ||= [parent.try(:slug), slug].compact.join("/")
  end

  def dependent_tags
    [] # should be overridden in subclasses
  end

  def top_level_mainstream_browse_page?
    false # should be overridden in subclasses
  end

private

  def parent_is_not_a_child
    if parent.present? && parent.parent_id.present?
      errors.add(:parent, "is a child tag")
    end
  end

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end

  def cannot_change_slug
    if slug_changed? && !new_record?
      errors.add(:slug, "cannot change a slug once saved")
    end
  end
end
