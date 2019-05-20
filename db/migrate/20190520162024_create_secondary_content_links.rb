class CreateSecondaryContentLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :secondary_content_links do |t|
      t.string :base_path
      t.string :title
      t.string :content_id
      t.string :publishing_app
      t.string :schema_name
      t.references :step_by_step_page, foreign_key: true
    end
  end
end
