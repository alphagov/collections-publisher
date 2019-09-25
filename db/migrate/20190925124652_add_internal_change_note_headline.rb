class AddInternalChangeNoteHeadline < ActiveRecord::Migration[5.2]
  def change
    add_column :internal_change_notes, :headline, :string
    InternalChangeNote.update_all(headline: 'Internal note')
  end
end
