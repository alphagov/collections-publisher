class CreateContentGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :content_groups do |t|
      t.references :coronavirus_sub_section, foreign_key: true, null: false
      t.string :header
      t.string :links
      t.integer :position

      t.timestamps
    end
  end
end
