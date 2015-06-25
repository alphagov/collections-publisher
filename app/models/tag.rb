# == Schema Information
#
# Table name: tags
#
#  id               :integer          not null, primary key
#  type             :string(255)
#  slug             :string(255)      not null
#  title            :string(255)      not null
#  description      :string(255)
#  parent_id        :integer
#  created_at       :datetime
#  updated_at       :datetime
#  content_id       :string(255)      not null
#  state            :string(255)      not null
#  dirty            :boolean          default(FALSE), not null
#  beta             :boolean          default(FALSE)
#  published_groups :text(16777215)
#
# Indexes
#
#  index_tags_on_content_id          (content_id) UNIQUE
#  index_tags_on_slug_and_parent_id  (slug,parent_id) UNIQUE
#  tags_parent_id_fk                 (parent_id)
#

require 'securerandom'

class Tag < ActiveRecord::Base
  include AASM
  include ActiveModel::Dirty

  belongs_to :parent, class_name: 'Tag'
  has_many :children, class_name: 'Tag', foreign_key: :parent_id

  has_many :tag_associations, foreign_key: :from_tag_id
  has_many :reverse_tag_associations, foreign_key: :to_tag_id,
           class_name: "TagAssociation"

  has_many :lists
  has_many :list_items, through: :lists

  has_many :redirects

  validates :slug, :title, :content_id, presence: true
  validates :slug, uniqueness: { scope: ["parent_id"] }, format: { with: /\A[a-z0-9-]*\z/ }
  validate :parent_is_not_a_child
  validate :cannot_change_slug

  before_validation :generate_content_id, on: :create

  scope :only_parents, -> { where('parent_id IS NULL') }
  scope :only_children, -> { where('parent_id IS NOT NULL') }
  scope :in_alphabetical_order, -> { order('title ASC') }

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

  def self.sorted_parents
    only_parents.includes(children: [:lists]).order(:title)
  end

  def sorted_children
    children.sort_by(&:title)
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
    update_columns(:dirty => true)
  end

  def web_url
    Plek.new.website_root + base_path
  end

  # returns unsaved ListItems for content tagged to this tag, but not in a
  # list.
  def uncategorized_list_items
    curated_api_urls = list_items.map(&:api_url)
    list_items_from_contentapi.reject {|li| curated_api_urls.include?(li.api_url) }
  end

  def list_items_from_contentapi
    @_list_items_from_contentapi ||= begin
      CollectionsPublisher.services(:content_api)
        .with_tag(full_slug, legacy_tag_type, draft: true)
        .map { |content_blob|
          ListItem.new(title: content_blob.title, api_url: content_blob.id)
        }
    rescue GdsApi::HTTPNotFound
      []
    end
  end

  def legacy_tag_type
    nil
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
    @full_slug ||= [parent.try(:slug), slug].compact.join('/')
  end

  def dependent_tags
    [] # should be overridden in subclasses
  end

private

  def parent_is_not_a_child
    if parent.present? && parent.parent_id.present?
      errors.add(:parent, 'is a child tag')
    end
  end

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end

  def cannot_change_slug
    if slug_changed? && !new_record?
      errors.add(:slug, 'cannot change a slug once saved')
    end
  end
end
