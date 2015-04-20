class FixUserUidField < ActiveRecord::Migration
  def up
    change_column :users, :uid, :string, :null => false
  end

  def down
    change_column :users, :uid, :string, :null => true
  end
end
