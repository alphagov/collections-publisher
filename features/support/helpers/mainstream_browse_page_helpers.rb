module MainstreamBrowsePageHelpers

  def create_mainstream_browse_page(slug:, title:, description: '')
    visit new_mainstream_browse_page_path

    fill_in_mainstream_browse_fields(
      slug: slug,
      title: title,
      description: description
    )
  end

  def create_child_mainstream_browse_page(parent:, slug:, title:, description: '')
    visit mainstream_browse_pages_path

    click_on parent
    click_on 'Add child page'

    fill_in_mainstream_browse_fields(
      slug: slug,
      title: title,
      description: description
    )
  end

  def fill_in_mainstream_browse_fields(slug:, title:, description:)
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

  def publish_mainstream_browse_page(existing_title)
    visit mainstream_browse_pages_path

    click_on existing_title
    click_on 'Publish browse page'
  end

  def check_for_mainstream_browse_page(title:, description: '')
    visit mainstream_browse_pages_path

    expect(page).to have_content(title)

    click_on title

    expect(page).to have_content(title)
    expect(page).to have_content(description)
  end

  def check_for_child_mainstream_browse_page(parent:, title:, description: '')
    visit mainstream_browse_pages_path

    click_on parent
    expect(page).to have_content(title)

    click_on title
    expect(page).to have_content(description)
  end

  def check_state_of_mainstream_browse_page(title:, state:)
    visit mainstream_browse_pages_path
    click_on title

    within '.attributes' do
      expect(page).to have_content(state)
    end
  end

end

World(MainstreamBrowsePageHelpers)
