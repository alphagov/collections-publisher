class AddFeaturedLinkToSubSections < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_sections, :featured_link, :string
  end
end
