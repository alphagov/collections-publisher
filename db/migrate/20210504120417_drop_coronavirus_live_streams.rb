class DropCoronavirusLiveStreams < ActiveRecord::Migration[6.0]
  def change
    drop_table :coronavirus_live_streams do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "url", null: false
      t.string "formatted_stream_date"
    end
  end
end
