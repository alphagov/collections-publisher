class AddRedirectUniqueness < ActiveRecord::Migration
  def change
    add_index :redirects, :from_base_path, :unique => true
  end
end
