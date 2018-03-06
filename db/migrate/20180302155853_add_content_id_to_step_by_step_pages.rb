class AddContentIdToStepByStepPages < ActiveRecord::Migration[5.1]
  def change
    add_column :step_by_step_pages, :content_id, :string

    StepByStepPage.find_each do |step|
      step.update_column :content_id, SecureRandom.uuid
    end

    change_column_null :step_by_step_pages, :content_id, false
    add_index :step_by_step_pages, :content_id, unique: true
  end
end
