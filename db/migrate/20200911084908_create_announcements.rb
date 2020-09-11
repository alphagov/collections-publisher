class CreateAnnouncements < ActiveRecord::Migration[6.0]
  def change
    create_table :announcements do |t|
      t.bigint :coronavirus_page_id
      t.string :text
      t.string :href
      t.datetime :published_at

      t.timestamps
    end
  end
end
