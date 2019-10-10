class AddAuthBypassIdColumnToStepByStepPages < ActiveRecord::Migration[5.2]
  def change
    add_column :step_by_step_pages, :auth_bypass_id, :string
  end
end
