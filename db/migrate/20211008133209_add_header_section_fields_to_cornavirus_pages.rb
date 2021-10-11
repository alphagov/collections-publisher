class AddHeaderSectionFieldsToCornavirusPages < ActiveRecord::Migration[6.1]
  def change
    change_table :coronavirus_pages, bulk: true do |t|
      t.string :header_title
      t.text :header_body
      t.text :header_link_url
      t.text :header_link_text
    end
  end
end
