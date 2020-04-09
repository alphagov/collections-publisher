class CreateLiveStream < ActiveRecord::Migration[6.0]
  def change
    create_table :live_streams do |t|
      t.boolean :state, default: false
      t.timestamps
    end
  end
end
