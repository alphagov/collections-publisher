class AddPositionToSubSection < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_sections, :position, :integer
  end
end
