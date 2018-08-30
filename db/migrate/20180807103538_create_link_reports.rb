class CreateLinkReports < ActiveRecord::Migration[5.2]
  def change
    create_table :link_reports do |t|
      t.integer :batch_id
      t.datetime :completed
      t.references :step, foreign_key: true

      t.timestamps
    end
  end
end
