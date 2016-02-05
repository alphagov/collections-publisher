class RemoveRedirectsTable < ActiveRecord::Migration
  def up
    drop_table :redirects
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "redirects table can't be recreated"
  end
end
