class CreateInternalChangeNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_change_notes do |t|
      t.string :author
      t.text :description
      t.references :step_by_step_page, foreign_key: true
      t.datetime :created_at
    end
  end
end
