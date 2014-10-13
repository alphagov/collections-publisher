module MainstreamBrowsePageHelpers

  def create_mainstream_browse_page(slug:, title:, description: '')
    visit new_mainstream_browse_page_path

    fill_in 'Slug', with: slug
    fill_in 'Title', with: title
    fill_in 'Description', with: description

    click_on 'Create'
  end

  def update_mainstream_browse_page(existing_title, title: '', description: '')
    visit mainstream_browse_pages_path

    click_on existing_title
    click_on 'Edit'

    fill_in 'Title', with: title
    fill_in 'Description', with: description

    click_on 'Save'
  end

  def check_for_mainstream_browse_page(title:, description: '')
    visit mainstream_browse_pages_path

    expect(page).to have_content(title)

    click_on title

    expect(page).to have_content(title)
    expect(page).to have_content(description)
  end

end

World(MainstreamBrowsePageHelpers)
