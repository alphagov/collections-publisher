class RemoveForeignKeyOnSubSections < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :sub_sections, :coronavirus_pages, column: :coronavirus_pages_id
  end
end
