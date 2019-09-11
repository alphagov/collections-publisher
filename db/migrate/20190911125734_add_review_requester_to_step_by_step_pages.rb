class AddReviewRequesterToStepByStepPages < ActiveRecord::Migration[5.2]
  def change
    add_column :step_by_step_pages, :review_requester_id, :string
    add_foreign_key :step_by_step_pages, :users, column: :review_requester_id, primary_key: 'uid'
  end
end
