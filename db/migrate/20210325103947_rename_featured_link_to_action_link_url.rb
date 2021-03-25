class RenameFeaturedLinkToActionLinkUrl < ActiveRecord::Migration[6.0]
  def change
    rename_column :coronavirus_sub_sections, :featured_link, :action_link_url
  end
end
