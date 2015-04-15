# == Schema Information
#
# Table name: lists
#
#  id        :integer          not null, primary key
#  name      :string(255)
#  sector_id :string(255)
#  index     :integer          default(0), not null
#  dirty     :boolean          default(TRUE), not null
#
# Indexes
#
#  index_lists_on_sector_id  (sector_id)
#

class List < ActiveRecord::Base
  has_many :contents, dependent: :destroy

  def sector
    @sector ||= Sector.find(sector_id)
  end

  def tagged_contents
    @tagged_contents ||= contents.order(:index).select {|c| tagged_api_urls.include?(c.api_url) }
  end

  def untagged_contents
    @tagged_contents ||= contents - tagged_contents
  end

  def mark_as_published
    self.dirty = false
  end

  def mark_as_published!
    mark_as_published
    save
  end

private

  def tagged_api_urls
    @tagged_api_urls ||= sector.contents_from_api.map(&:api_url)
  end
end
