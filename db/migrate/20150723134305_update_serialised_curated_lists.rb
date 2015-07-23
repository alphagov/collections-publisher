class UpdateSerialisedCuratedLists < ActiveRecord::Migration
  def up
    Tag.find_each do |tag|
      next if tag.published_groups.empty?

      tag.published_groups.each do |group|
        group['contents'].map! do |url|
          URI.parse(url).path.chomp('.json')
        end
      end
      tag.save!
    end
  end

  def down
    base_url = Plek.find('contentapi')
    Tag.find_each do |tag|
      next if tag.published_groups.empty?

      tag.published_groups.each do |group|
        group['contents'].map! do |path|
          base_url + path + '.json'
        end
      end
      tag.save!
    end
  end
end
