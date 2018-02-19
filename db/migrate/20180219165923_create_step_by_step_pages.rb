class CreateStepByStepPages < ActiveRecord::Migration[5.1]
  def change
    create_table :step_by_step_pages do |t|
      t.string "title"
      t.string "base_path"
      t.text "introduction"
      t.text "description"
      t.timestamps
    end
  end
end
