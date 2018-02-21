class CreateSteps < ActiveRecord::Migration[5.1]
  def change
    create_table :steps do |t|
      t.string "title"
      t.string "logic"
      t.boolean "optional"
      t.text "contents"
      t.string "optional_heading"
      t.text "optional_contents"
      t.integer "position"
      t.references :step_by_step_page, foreign_key: true
      
      t.timestamps
    end
  end
end
