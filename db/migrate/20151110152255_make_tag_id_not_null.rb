class MakeTagIdNotNull < ActiveRecord::Migration
  def change
    change_column_null :newest_redirects, :tag_id, false
  end
end
