class AddScheduledAtToStepByStepPages < ActiveRecord::Migration[5.2]
  def change
    add_column :step_by_step_pages, :scheduled_at, :datetime
  end
end
