class AddBetaToTags < ActiveRecord::Migration
  def change
    add_column :tags, :beta, :boolean, default: false
  end
end
