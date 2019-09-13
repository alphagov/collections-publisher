class AddReviewerToStepByStepPages < ActiveRecord::Migration[5.2]
  def change
    add_column :step_by_step_pages, :reviewer_id, :string
    add_foreign_key :step_by_step_pages, :users, column: :reviewer_id, primary_key: 'uid'
  end
end
