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

  def contents_from_api
    @contents_from_api ||= CollectionsPublisher.services(:content_api)
      .with_tag(slug, 'specialist_sector', draft: true)
      .map { |content_blob|
        Content.new(title: content_blob.title, api_url: content_blob.id)
      }
  end

  def contents
    lists.map(&:contents).flatten
  end

  def uncategorized_contents
    api_urls = contents.map(&:api_url)
    contents_from_api.reject {|content| api_urls.include?(content.api_url) }
  end

  def untagged_contents
    @untagged_contents ||= lists.map(&:untagged_contents).flatten
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
