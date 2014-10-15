require 'spec_helper'

describe 'listing browse pages' do

  it 'only shows parent browse pages' do
    parent_browse_pages = create_list(:mainstream_browse_page, 5)
    child_browse_pages = create_list(:mainstream_browse_page, 5, parent: parent_browse_pages.first )

    visit mainstream_browse_pages_path

    within '.mainstream-browse-pages' do
      parent_browse_pages.each do |parent_browse_page|
        expect(page).to have_link(parent_browse_page.title,
                                  href: mainstream_browse_page_path(parent_browse_page))
      end

      child_browse_pages.each do |child_browse_page|
        expect(page).not_to have_content(child_browse_page.title)
      end
    end
  end

end
