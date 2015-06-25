class AddBrowseRedirects < ActiveRecord::Migration
  def up
    [
      'business',
      'visas-immigration',
    ].each do |slug|
      page = MainstreamBrowsePage.only_parents.where(:slug => slug).first
      raise "Failed to find top-level browse page with slug #{slug}" unless page

      Redirect.create!(
        :tag => page,
        :original_tag_base_path => "/#{slug}",
        :from_base_path => "/#{slug}",
        :to_base_path => "/browse/#{slug}",
      )
    end
  end
end
