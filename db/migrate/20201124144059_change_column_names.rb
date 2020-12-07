class ChangeColumnNames < ActiveRecord::Migration[6.0]
  def change
    change_table :announcements, bulk: true do |t|
      t.rename :text, :title
      t.rename :href, :path
    end
  end
end
