class CreateCoronavirusPages < ActiveRecord::Migration[6.0]
  def change
    create_table :coronavirus_pages do |t|
      t.string :sections_title
      t.string :base_path
      t.timestamps
    end
  end
end
