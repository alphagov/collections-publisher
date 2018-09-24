class ChangeColumnNameToAssignedTo < ActiveRecord::Migration[5.2]
  def change
    rename_column :step_by_step_pages, :draft_created_by, :assigned_to
  end
end
