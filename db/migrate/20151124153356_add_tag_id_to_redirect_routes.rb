class AddTagIdToRedirectRoutes < ActiveRecord::Migration
  def up
    add_column :redirect_routes, :tag_id, :integer
    add_foreign_key :redirect_routes, :tags
    add_index :redirect_routes, [:tag_id], using: :btree
    execute update_statement
  end

  def down
    remove_foreign_key :redirect_routes, :tags
    remove_column :redirect_routes, :tag_id
  end
end

def update_statement
  "UPDATE redirect_routes rr
  INNER JOIN (SELECT r.id, r.tag_id FROM newest_redirects r) AS j ON (rr.redirect_id = j.id)
  SET rr.tag_id = j.tag_id"
end
