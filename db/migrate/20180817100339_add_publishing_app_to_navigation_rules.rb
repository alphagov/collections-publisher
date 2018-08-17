class AddPublishingAppToNavigationRules < ActiveRecord::Migration[5.2]
  def up
    add_column :navigation_rules, :publishing_app, :string
    add_column :navigation_rules, :schema_name, :string

    NavigationRule.reset_column_information
    NavigationRule.all.each do |rule|
      begin
        content_item = Services.publishing_api.get_content(rule.content_id)
        rule.publishing_app = content_item["publishing_app"]
        rule.schema_name = content_item["schema_name"]
        rule.save
      rescue GdsApi::HTTPNotFound
      end
    end
  end

  def down
    remove_column :navigation_rules, :publishing_app
    remove_column :navigation_rules, :schema_name
  end
end
