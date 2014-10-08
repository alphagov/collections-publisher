class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :type
      t.string :slug, null: false
      t.string :title, null: false
      t.string :description
      t.integer :parent_id
      t.timestamps
    end
  end
end
