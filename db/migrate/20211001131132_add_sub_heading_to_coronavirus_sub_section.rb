class AddSubHeadingToCoronavirusSubSection < ActiveRecord::Migration[6.1]
  def change
    add_column :coronavirus_sub_sections, :sub_heading, :string
  end
end
