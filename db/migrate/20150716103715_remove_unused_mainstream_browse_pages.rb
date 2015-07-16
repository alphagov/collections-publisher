class RemoveUnusedMainstreamBrowsePages < ActiveRecord::Migration

  SLUGS = %w(
    time-off-new-child
    child-into-care
  )

  def self.up
    SLUGS.each { |slug|
      tag = Tag.where(slug: slug)
      Tag.destroy(tag) if tag
    }
  end

  def self.down
    # Nothing to do here
  end

end
