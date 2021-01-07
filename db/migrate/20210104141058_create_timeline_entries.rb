class CreateTimelineEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :timeline_entries do |t|
      t.references :coronavirus_page, foreign_key: true, null: false
      t.string :content, null: false
      t.string :heading, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
