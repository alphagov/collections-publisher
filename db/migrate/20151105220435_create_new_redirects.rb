class CreateNewRedirects < ActiveRecord::Migration
  def change
    create_table :newest_redirects do |t|
      t.references :tag, index: true, foreign_key: true
      t.string :original_tag_base_path
      t.timestamps null: false
    end

    add_index :newest_redirects, :original_tag_base_path, unique: true
  end
end
