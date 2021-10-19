class AddHeaderLinkWrapTextFields < ActiveRecord::Migration[6.1]
  def up
    change_table :coronavirus_pages, bulk: true do |t|
      t.remove :header_link_text
      t.string :header_link_pre_wrap_text
      t.string :header_link_post_wrap_text
    end
  end

  def down
    change_table :coronavirus_pages, bulk: true do |t|
      t.text :header_link_text
      t.remove :header_link_pre_wrap_text
      t.remove :header_link_post_wrap_text
    end
  end
end
