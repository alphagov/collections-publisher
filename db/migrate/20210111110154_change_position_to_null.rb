class ChangePositionToNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:timeline_entries, :position, true)
  end
end
