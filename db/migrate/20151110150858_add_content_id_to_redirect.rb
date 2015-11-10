class AddContentIdToRedirect < ActiveRecord::Migration
  def up
    add_column :newest_redirects, :content_id, :string

    Redirect.find_each do |redirect|
      redirect.update_column :content_id, SecureRandom.uuid
    end

    change_column_null :newest_redirects, :content_id, false
    add_index :newest_redirects, :content_id, unique: true
  end

  def down
    remove_column :newest_redirects, :content_id
  end
end
