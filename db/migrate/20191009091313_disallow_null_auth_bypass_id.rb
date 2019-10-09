class DisallowNullAuthBypassId < ActiveRecord::Migration[5.2]
  def change
    change_column :step_by_step_pages, :auth_bypass_id, :string, null: false
  end
end
