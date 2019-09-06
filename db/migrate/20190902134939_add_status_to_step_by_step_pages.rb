class AddStatusToStepByStepPages < ActiveRecord::Migration[5.2]
  def change
    add_column :step_by_step_pages, :status, :string, null: false
  end
end
