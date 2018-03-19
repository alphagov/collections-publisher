class RemoveOptionalContentFromSteps < ActiveRecord::Migration[5.1]
  def change
    remove_column :steps, :optional_heading, :string
    remove_column :steps, :optional_contents, :text
  end
end
