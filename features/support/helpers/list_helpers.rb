module ListHelpers
  def visit_sector(sector_name)
    visit sectors_path
    click_on sector_name
  end

  def curate_list(sector_name:, list_name:, content:)
    visit_sector(sector_name)

    within '#new-list' do
      fill_in 'Name', with: list_name
      click_on 'Create'
    end

    list = List.where(name: list_name).first
    within "#list-#{list.id}-section" do
      content.each_with_index do |content_slug, index|
        fill_in 'API URL', with: content_api_url(slug: content_slug)
        fill_in 'Index', with: index
        click_on 'Add'
      end
    end
  end

  def create_list(name:, sector:, content:)
    list = FactoryGirl.create(:list, name: name, sector_id: sector)

    content.each do |content_slug|
      FactoryGirl.create(:content, api_url: content_api_url(slug: content_slug), list: list)
    end
  end

  def check_for_list_with_content(sector_name:, list_name:, content:)
    visit_sector(sector_name)

    list = List.where(name: list_name).first
    list_id = list.try(:id) || 'uncategorized'

    within "#list-#{list_id}-section" do
      expect(page).to have_content(list_name)

      content.each_with_index do |content_slug, index|
        expect(page).to have_css(
          "tbody tr:nth-child(#{index+2}) .api-url",
          text: content_api_url(slug: content_slug)
        )
      end
    end
  end

  def check_for_list_without_content(sector_name:, list_name:, content:)
    visit_sector(sector_name)

    list = List.where(name: list_name).first

    raise "No list exists with that name" unless list

    within "#list-#{list.id}-section" do
      content.each_with_index do |content_slug, index|
        expect(page).not_to have_content(content_api_url(slug: content_slug))
      end
    end
  end

  def check_for_untagged_content(sector_name:, content:)
    visit_sector(sector_name)

    within ".untagged-contents" do
      content.each do |content_slug|
        content_item = Content.where(api_url: content_api_url(slug: content_slug)).first
        expect(page).to have_content(content_item.title)
      end
    end
  end

  def publish_sector(name)
    visit_sector(name)

    click_on 'Publish'
  end

  def check_cannot_publish
    expect(page).not_to have_css('button', text: 'Publish')
    expect(page).not_to have_css('input[type="submit"]', text: 'Publish')
    expect(page).not_to have_css('input[type="submit"][value="Publish"]')
  end

private

  def content_api_url(slug:)
    "#{Plek.new.find('contentapi')}/#{slug}.json"
  end
end

World(ListHelpers)
