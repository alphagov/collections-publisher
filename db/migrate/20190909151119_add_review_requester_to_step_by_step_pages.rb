class AddReviewRequesterToStepByStepPages < ActiveRecord::Migration[5.2]
  def change
    add_column :step_by_step_pages, :review_requester, :string
  end
end
