class CreateContent < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.string :api_url
      t.integer :index, null: false, default: 0
      t.references :list
      t.timestamps
    end
  end
end
