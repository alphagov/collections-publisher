class ChangeIncludeInLinksToString < ActiveRecord::Migration[5.2]
  def up
    add_column :navigation_rules, :include_in_links_string, :string, default: 'always', null: false

    NavigationRule.where(include_in_links: false).update_all(include_in_links_string: 'conditionally')

    remove_column :navigation_rules, :include_in_links
    rename_column :navigation_rules, :include_in_links_string, :include_in_links
  end

  def down
    add_column :navigation_rules, :include_in_links_bool, :boolean, default: true, null: false

    NavigationRule.where(include_in_links: ['conditionally', 'never']).update_all(include_in_links_bool: false)

    remove_column :navigation_rules, :include_in_links
    rename_column :navigation_rules, :include_in_links_bool, :include_in_links
  end
end
