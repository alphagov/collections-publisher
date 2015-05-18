require 'rails_helper'

RSpec.describe 'listing mainstream browse pages' do
  before :each do
    stub_user.permissions << "GDS Editor"
  end

  it "doesn't show anything for non-editors" do
    stub_user.permissions = ['signin']

    visit mainstream_browse_pages_path

    expect(page.status_code).to eql 403
  end

  it 'shows parent and child browse pages' do
    # Given there are browse pages with children
    parent_browse_pages = create_list(:mainstream_browse_page, 5)
    child_browse_pages = create_list(:mainstream_browse_page, 5, parent: parent_browse_pages.first )

    # When I visit the browse page
    visit mainstream_browse_pages_path

    # Then I should see a list of children
    within '.tags-list' do
      parent_browse_pages.each do |parent_browse_page|
        expect(page).to have_link(parent_browse_page.title,
                                  href: mainstream_browse_page_path(parent_browse_page))
      end
    end
  end

  context 'link to add a child page' do
    let(:parent_browse_page) { create(:mainstream_browse_page) }
    let(:child_browse_page) { create(:mainstream_browse_page, parent: parent_browse_page) }

    it 'shows the link given a top-level parent' do
      # When I visit a parent browse page
      visit mainstream_browse_page_path(parent_browse_page)

      # Then I should be able to add a child page
      expect(page).to have_link('Add child page')
    end

    it 'does not show the link given a child page' do
      # When I visit a child browse page
      visit mainstream_browse_page_path(child_browse_page)

      # Then I should not be able to add a child page
      expect(page).to_not have_link('Add child page')
    end
  end
end
