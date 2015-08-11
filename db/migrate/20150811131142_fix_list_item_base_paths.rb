class FixListItemBasePaths < ActiveRecord::Migration
  def up
    ListItem.find_each do |item|
      item.base_path = item.base_path.gsub('%2F', '/')
      item.save!
    end
  end
end
