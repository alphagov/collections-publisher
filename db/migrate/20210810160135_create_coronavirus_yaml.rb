class CreateCoronavirusYaml < ActiveRecord::Migration[6.1]
  def change
    create_table :coronavirus_yamls do |t|
      t.text :content
      t.bigint :coronavirus_page_id

      t.timestamps
    end
  end
end
