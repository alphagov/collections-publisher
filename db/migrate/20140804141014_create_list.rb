class CreateList < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.string :sector_id
      t.timestamp
    end
  end
end
