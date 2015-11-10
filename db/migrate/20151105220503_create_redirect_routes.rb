class CreateRedirectRoutes < ActiveRecord::Migration
  def change
    create_table :redirect_routes do |t|
      t.references :redirect, index: true
      t.string :from_base_path
      t.string :to_base_path
      t.timestamps null: false
    end

    add_index :redirect_routes, :from_base_path, unique: true
  end
end
