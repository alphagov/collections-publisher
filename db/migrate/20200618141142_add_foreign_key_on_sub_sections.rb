class AddForeignKeyOnSubSections < ActiveRecord::Migration[6.0]
  def change
    rename_column :sub_sections, :coronavirus_pages_id, :coronavirus_page_id
    add_foreign_key :sub_sections, :coronavirus_pages
  end
end
