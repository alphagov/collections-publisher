class StepByStepScheduleChangeNote < ActiveRecord::Migration[5.2]
  def change
    add_column :step_by_step_pages, :update_type, :integer
    add_column :step_by_step_pages, :public_change_note, :text
  end
end
