class AddEditionNumberToInternalChangeNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :internal_change_notes, :edition_number, :integer, default: nil
  end
end
