class Sector < SimpleDelegator
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def self.find(slug)
    all_children.find {|s| s.slug == slug }
  end

  def self.all_children
    CollectionsPublisher.services(:content_api)
      .tags('specialist_sector', draft: true, sort: 'alphabetical')
      .select(&:parent)
      .map {|tag| self.new(tag) }
  end

  def lists
    List.where(sector_id: slug)
  end

  def ordered_lists
    lists.order(:index)
  end

  def list_items_from_api
    @list_items_from_api ||= CollectionsPublisher.services(:content_api)
      .with_tag(slug, 'specialist_sector', draft: true)
      .map { |content_blob|
        ListItem.new(title: content_blob.title, api_url: content_blob.id)
      }
  end

  def list_items
    lists.map(&:list_items).flatten
  end

  def uncategorized_list_items
    api_urls = list_items.map(&:api_url)
    list_items_from_api.reject {|list_item| api_urls.include?(list_item.api_url) }
  end

  def untagged_list_items
    @untagged_list_items ||= lists.map(&:untagged_list_items).flatten
  end

  def to_param
    slug
  end

  def draft?
    state == 'draft'
  end

  def dirty?
    lists.any?(&:dirty?)
  end
end
