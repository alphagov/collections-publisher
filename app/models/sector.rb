class Sector < SimpleDelegator
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def self.find(slug)
    all_children.find {|s| s.slug == slug }
  end

  def self.all_children
    @all_children ||= CollectionsPublisher.services(:content_api)
      .tags('specialist_sector', draft: true)
      .select(&:parent)
      .map {|tag| self.new(tag) }
  end

  def lists
    List.where(sector_id: slug)
  end

  def all_content_api_urls
    @all_content_api_urls ||= CollectionsPublisher.services(:content_api)
      .with_tag(slug, 'specialist_sector')
      .map(&:id)
  end

  def to_param
    slug
  end
end
