class AddDraftCreatedByToStepByStepPages < ActiveRecord::Migration[5.2]
  def change
    add_column :step_by_step_pages, :draft_created_by, :string
  end
end
