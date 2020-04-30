class AddFormattedStreamDateToLiveStream < ActiveRecord::Migration[6.0]
  def change
    add_column :live_streams, :formatted_stream_date, :string
  end
end
