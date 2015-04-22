class FixTagSlugs < ActiveRecord::Migration
  def up
    Tag.where('parent_id IS NOT NULL').includes(:parent).find_each do |tag|
      next unless tag.slug.include?('/')

      parent_slug, child_slug = tag.slug.split('/', 2)

      unless parent_slug == tag.parent.slug
        raise "Tag slug mismatch - parent: #{tag.parent.slug}, child: #{tag.slug}"
      end

      puts "will fix #{tag.slug} -> #{child_slug}"
      tag.update_columns(:slug => child_slug)
    end
  end
end
