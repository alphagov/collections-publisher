class AddForeignKeyToReviewRequester < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :step_by_step_pages, :users, column: :review_requester, primary_key: 'uid'
  end
end
