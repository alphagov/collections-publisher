class ChangeListItemApiUrlToBasePath < ActiveRecord::Migration
  def up
    rename_column :list_items, :api_url, :base_path
    ListItem.find_each do |item|
      base_path = URI.parse(item.base_path).path.chomp(".json")
      item.update_column(:base_path, base_path)
    end
  end

  def down
    ListItem.find_each do |item|
      api_url = Plek.find('contentapi') + item.base_path + '.json'
      item.update_column(:base_path, api_url)
    end
    rename_column :list_items, :base_path, :api_url
  end
end
