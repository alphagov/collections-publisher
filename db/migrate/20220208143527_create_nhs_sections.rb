class CreateNhsSections < ActiveRecord::Migration[6.1]
  def change
    create_table :nhs_sections do |t|
      t.string :heading
      t.text :sections

      t.timestamps
    end
  end
end
