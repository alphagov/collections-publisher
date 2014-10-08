module MainstreamBrowsePageHelpers

  def create_mainstream_browse_page(slug:, title:, description: '')
    visit new_mainstream_browse_page_path

    fill_in 'Slug', with: slug
    fill_in 'Title', with: title
    fill_in 'Description', with: description

    click_on 'Create'
  end

  def check_for_mainstream_browse_page(title:)
    visit mainstream_browse_pages_path

    expect(page).to have_content(title)
  end

end

World(MainstreamBrowsePageHelpers)
