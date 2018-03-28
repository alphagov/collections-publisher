class AddPublishAndDraftTimesToStepByStepPage < ActiveRecord::Migration[5.1]
  def change
    add_column :step_by_step_pages, :published_at, :datetime
    add_column :step_by_step_pages, :draft_updated_at, :datetime
  end
end
