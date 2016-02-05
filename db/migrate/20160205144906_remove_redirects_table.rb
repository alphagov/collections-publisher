class RemoveRedirectsTable < ActiveRecord::Migration
  def change
    drop_table :redirects
  end
end
