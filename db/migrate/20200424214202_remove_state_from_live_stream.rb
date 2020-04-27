class RemoveStateFromLiveStream < ActiveRecord::Migration[6.0]
  def change
    remove_column :live_streams, :state
  end
end
