module ListHelpers
  def curate_list(sector_name:, list_name:, content:)
    visit sectors_path
    click_on sector_name

    within '#new-list' do
      fill_in 'Name', with: list_name
      click_on 'Create'
    end

    list = List.where(name: list_name).first
    within "#list-#{list.id}-section" do
      content.each_with_index do |content_slug, index|
        fill_in 'API URL', with: "#{Plek.new.find('contentapi')}/#{content_slug}.json"
        fill_in 'Index', with: index
        click_on 'Add'
      end
    end
  end

  def check_for_list_with_content(sector_name:, list_name:, content:)
    visit sectors_path
    click_on sector_name

    list = List.where(name: list_name).first
    list_id = list.try(:id) || 'uncategorized'

    within "#list-#{list_id}-section" do
      expect(page).to have_content(list_name)

      content.each_with_index do |content_slug, index|
        expect(page).to have_css(
          "tbody tr:nth-child(#{index+2}) .api-url",
          text: "#{Plek.new.find('contentapi')}/#{content_slug}.json"
        )
      end
    end
  end
end

World(ListHelpers)
