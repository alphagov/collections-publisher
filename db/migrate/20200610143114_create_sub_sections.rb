class CreateSubSections < ActiveRecord::Migration[6.0]
  def change
    create_table :sub_sections do |t|
      t.string :title
      t.text :content
      t.references :coronavirus_pages, foreign_key: true

      t.timestamps
    end
  end
end
