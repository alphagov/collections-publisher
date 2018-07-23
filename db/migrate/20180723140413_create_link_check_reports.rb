class CreateLinkCheckReports < ActiveRecord::Migration[5.2]
  def change
    create_table :link_check_reports do |t|
      t.integer :batch_id
      t.datetime :date_requested
      t.string :status
      t.integer :ste_nav_id

      t.timestamps
    end
  end
end
