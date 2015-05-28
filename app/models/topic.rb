# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  slug        :string(255)      not null
#  title       :string(255)      not null
#  description :string(255)
#  parent_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#  content_id  :string(255)      not null
#  state       :string(255)      not null
#  dirty       :boolean          default(FALSE), not null
#  beta        :boolean          default(FALSE)
#
# Indexes
#
#  index_tags_on_content_id          (content_id) UNIQUE
#  index_tags_on_slug_and_parent_id  (slug,parent_id) UNIQUE
#  tags_parent_id_fk                 (parent_id)
#

class Topic < Tag
  has_many :mainstream_browse_pages, through: :reverse_tag_associations, source: :from_tag
  has_many :lists
  has_many :list_items, :through => :lists

  # returns unsaved ListItems for content tagged to this topic, but not in a
  # list.
  def uncategorized_list_items
    curated_api_urls = list_items.map(&:api_url)
    list_items_from_contentapi.reject {|li| curated_api_urls.include?(li.api_url) }
  end

  # returns ListItems for content that's no longer tagged to this topic.
  def untagged_list_items
    @_untagged_list_items ||= lists.map(&:untagged_list_items).flatten
  end

  def list_items_from_contentapi
    @_list_items_from_contentapi ||= begin
      CollectionsPublisher.services(:content_api)
        .with_tag(panopticon_slug, 'specialist_sector', draft: true)
        .map { |content_blob|
          ListItem.new(title: content_blob.title, api_url: content_blob.id)
        }
    rescue GdsApi::HTTPNotFound
      []
    end
  end

  # FIXME: remove this once we're using content_id's in URLs everywhere.
  def panopticon_slug
    self.base_path[1..-1]
  end
end
