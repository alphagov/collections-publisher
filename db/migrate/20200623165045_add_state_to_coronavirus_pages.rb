class AddStateToCoronavirusPages < ActiveRecord::Migration[6.0]
  def change
    add_column :coronavirus_pages, :state, :string, default: "draft"
    change_column_null :coronavirus_pages, :state, false
  end
end
