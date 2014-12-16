require 'spec_helper'

describe 'listing browse pages' do

  it 'only shows parent browse pages' do
    parent_browse_pages = create_list(:mainstream_browse_page, 5)
    child_browse_pages = create_list(:mainstream_browse_page, 5, parent: parent_browse_pages.first )

    visit mainstream_browse_pages_path

    within '.tags-list' do
      parent_browse_pages.each do |parent_browse_page|
        expect(page).to have_link(parent_browse_page.title,
                                  href: mainstream_browse_page_path(parent_browse_page))
      end

      child_browse_pages.each do |child_browse_page|
        expect(page).not_to have_content(child_browse_page.title)
      end
    end
  end

  context 'link to add a child page' do
    let(:parent_browse_page) { create(:mainstream_browse_page) }
    let(:child_browse_page) { create(:mainstream_browse_page, parent: parent_browse_page) }

    it 'shows the link given a top-level parent' do
      visit mainstream_browse_page_path(parent_browse_page)

      expect(page).to have_link('Add child page')
    end

    it 'does not show the link given a child page' do
      visit mainstream_browse_page_path(child_browse_page)

      expect(page).to_not have_link('Add child page')
    end
  end

end
