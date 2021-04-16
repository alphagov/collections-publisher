class AddActionLinkFieldsToCoronavirusSubSections < ActiveRecord::Migration[6.0]
  def change
    change_table :coronavirus_sub_sections, bulk: true do |t|
      t.string :action_link_content
      t.string :action_link_summary
    end
  end
end
