class CreateLinkCheckReports < ActiveRecord::Migration[5.2]
  def change
    create_table :link_check_reports do |t|
      t.datetime :completed
      t.integer :batch_id
      t.references :step, foreign_key: true

      t.timestamps
    end
  end
end
