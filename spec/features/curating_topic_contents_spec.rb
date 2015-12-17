require 'rails_helper'

RSpec.feature "Curating topic contents" do
  include PublishingApiHelpers

  before :each do
    stub_put_content_links_and_publish_to_publishing_api
  end

  describe "Curating the content for a topic" do
    before :each do
      # Given a number of content items tagged to a topic
      oil_and_gas = create(:topic, :published, :slug => 'oil-and-gas', :title => 'Oil and Gas')
      create(:topic, :published, :slug => 'offshore', :title => 'Offshore', :parent => oil_and_gas)

      stub_any_call_to_rummager_with_documents([
        { title: 'Oil rig safety requirements', link: '/oil-rig-safety-requirements' },
        { title: 'Oil rig staffing', link: '/oil-rig-staffing' },
        { title: 'North sea shipping lanes', link: '/north-sea-shipping-lanes' },
        { title: 'Undersea piping restrictions', link: '/undersea-piping-restrictions' },
      ])
    end

    it "with javascript", :js => true do
      # When I arrange the content of that topic into lists
      visit_topic_list_curation_page

      within '#new-list' do
        fill_in 'Name', :with => 'Oil rigs'
        click_on 'Create'
      end

      # We need to scroll down first to see all the lists.
      page.driver.scroll_to 0, 100

      expect(page).to have_selector('h4', :text => 'Oil rigs')

      link_with_title('Oil rig staffing').drag_to droptarget_for_list('Oil rigs')
      link_with_title('Oil rig safety requirements').drag_to droptarget_for_list('Oil rigs')

      within :xpath, xpath_section_for('Oil rigs') do
        expect(page).to have_content('Oil rig safety requirements')
        expect(page).to have_content('Oil rig staffing')
        expect(page).not_to have_css(".working") # Wait until the AJAX call has completed
      end

      within '#new-list' do
        fill_in 'Name', :with => 'Piping'
        click_on 'Create'
      end

      expect(page).to have_selector('.list h4', :text => 'Piping')

      link_with_title('Undersea piping restrictions').drag_to droptarget_for_list('Piping')

      within :xpath, xpath_section_for('Piping') do
        expect(page).to have_content('Undersea piping restrictions')
        expect(page).not_to have_selector(".working") # Wait until the AJAX call has completed
      end

      # Then the content should be in the correct lists in the correct order
      visit_topic_list_curation_page

      within :xpath, xpath_section_for('Oil rigs') do
        titles = page.all('td.title').map(&:text)
        # Note: order reversed because we dragged the items to the top of the list above.
        expect(titles).to eq([
          'Oil rig staffing',
          'Oil rig staffing',
          'Oil rig safety requirements',
        ])
      end

      within :xpath, xpath_section_for('Piping') do
        titles = page.all('td.title').map(&:text)
        expect(titles).to eq([
          'Undersea piping restrictions',
        ])
      end

      # When I publish the topic
      content_id = extract_content_id_from(current_path)
      click_on('Publish changes to GOV.UK')


      #Then the curated lists should have been sent to the publishing API
      assert_publishing_api_put_item(
        content_id,
        {
          "details" => {
            "groups" => [
              { "name" => 'Oil rigs',
                "contents" => [
                  '/oil-rig-staffing',
                  '/oil-rig-staffing',
                  '/oil-rig-safety-requirements',
              ]},
              { "name" => 'Piping',
                "contents" => [
                  '/undersea-piping-restrictions',
              ]},
            ],
            "beta" => false,
            "internal_name" => "Oil and Gas / Offshore"
          }
        },
      )

      # And have been published and links sent
      assert_publishing_api_publish(content_id)
      assert_publishing_api_put_links(content_id)
    end

    it "without javascript" do
      # When I arrange the content of that topic into lists
      visit_topic_list_curation_page

      expect(page).to have_content('currently displayed in alphabetical order')

      within '#new-list' do
        fill_in 'Name', :with => 'Oil rigs'
        click_on 'Create'
      end

      within :xpath, xpath_section_for('Oil rigs') do
        fill_in 'Base Path', :with => '/oil-rig-safety-requirements'
        fill_in 'Index', :with => 0
        click_on 'Add'

        fill_in 'Base Path', :with => '/oil-rig-staffing'
        fill_in 'Index', :with => 1
        click_on 'Add'
      end

      within '#new-list' do
        fill_in 'Name', :with => 'Piping'
        click_on 'Create'
      end

      within :xpath, xpath_section_for('Piping') do
        fill_in 'Base Path', :with => '/undersea-piping-restrictions'
        fill_in 'Index', :with => 0
        click_on 'Add'
      end

      # Then the content should be in the correct lists in the correct order
      visit_topic_list_curation_page
      content_id = extract_content_id_from(current_path)

      within :xpath, xpath_section_for('Oil rigs') do
        base_paths = page.all('tr').map { |tr| tr['data-base-path'] }.compact

        expect(base_paths).to eq([
          '/oil-rig-safety-requirements',
          '/oil-rig-staffing',
        ])
      end

      within :xpath, xpath_section_for('Piping') do
        base_paths = page.all('tr').map { |tr| tr['data-base-path'] }.compact

        expect(base_paths).to eq([
          '/undersea-piping-restrictions',
        ])
      end

      # When I publish the topic
      click_on('Publish changes to GOV.UK')



      #Then the curated lists should have been sent to the publishing API
      assert_publishing_api_put_item(
        content_id,
        {
          "details" => {
            "groups" => [
              { "name" => 'Oil rigs',
                "contents" => [
                  '/oil-rig-safety-requirements',
                  '/oil-rig-staffing',
              ]},
              { "name" => 'Piping',
                "contents" => [
                  '/undersea-piping-restrictions',
              ]},
            ],
            "beta" => false,
            "internal_name" => "Oil and Gas / Offshore"
          }
        },
      )

      # And then be published and links sent
      assert_publishing_api_publish(content_id)
      assert_publishing_api_put_links(content_id)
    end
  end

  it "curating draft tags" do
    # Given a number of content items tagged to a draft topic
    oil_and_gas = create(:topic, :published, :slug => 'oil-and-gas', :title => 'Oil and Gas')
    create(:topic, :draft, :slug => 'offshore', :title => 'Offshore', :parent => oil_and_gas)

    stub_any_call_to_rummager_with_documents([
      { link: '/oil-rig-safety-requirements' },
    ])

    # Then I should be able to curate the draft topic
    visit_topic_list_curation_page

    # And I should not be able to publish the draft topic
    expect(page).not_to have_selector('button', :text => 'Publish')
    expect(page).not_to have_selector('input[type="submit"]', :text => "Publish")
    expect(page).not_to have_selector('input[type="submit"][value="Publish"]')
  end

  context "with a subtopic which has had content curated" do
    before :each do
      oil_and_gas = create(:topic, :published, :slug => 'oil-and-gas', :title => 'Oil and Gas')
      offshore = create(:topic, :published, :slug => 'offshore', :title => 'Offshore', :parent => oil_and_gas)

      stub_any_call_to_rummager_with_documents([
        { title: 'Oil rig safety requirements', link: '/oil-rig-safety-requirements' },
        { title: 'Oil rig staffing', link: '/oil-rig-staffing' },
        { title: 'North sea shipping lanes', link: '/north-sea-shipping-lanes' },
        { title: 'Undersea piping restrictions', link: '/undersea-piping-restrictions' },
      ])

      oil_rigs = create(:list, :tag => offshore, :name => 'Oil rigs', :index => 0)
      piping = create(:list, :tag => offshore, :name => 'Piping', :index => 1)

      create(:list_item, :list => oil_rigs, :index => 0, :title => 'Oil rig safety requirements', :base_path => '/oil-rig-safety-requirements')
      create(:list_item, :list => oil_rigs, :index => 1, :title => 'Oil rig staffing', :base_path => '/oil-rig-staffing')
      create(:list_item, :list => piping, :index => 0, :title => 'Undersea piping restrictions', :base_path => '/undersea-piping-restrictions')
      create(:list_item, :list => piping, :index => 1, :title => 'Non-existent', :base_path => '/non-existent')
    end

    it "viewing the topic curation page" do
      # When I visit the topic curation page
      visit_topic_list_curation_page

      # Then I should see the curated topic groups
      within '.curated-lists' do
        expect(list_titles_on_page).to eq([
          'Oil rigs',
          'Piping',
        ])

        within :xpath, xpath_section_for('Oil rigs') do
          titles = page.all('td.title').map(&:text)
          expect(titles).to eq([
            'Oil rig safety requirements',
            'Oil rig staffing',
          ])
        end

        within :xpath, xpath_section_for('Piping') do
          titles = page.all('td.title').map(&:text)
          expect(titles).to eq([
            'Undersea piping restrictions',
            'Tag was removed Non-existent',
          ])
        end
      end
    end

    it "editing a list name" do
      # When I visit the topic curation page
      visit_topic_list_curation_page

      # And I change the name of a list
      within :xpath, xpath_section_for('Oil rigs') do
        click_on "Edit name"
      end

      fill_in "Name", :with => 'Oil platforms'
      click_on "Update list"

      # Then I should see the updated list name
      within '.curated-lists' do
        expect(list_titles_on_page).to eq([
          'Oil platforms',
          'Piping',
        ])
      end

      # And it should retain its content
      within :xpath, xpath_section_for('Oil platforms') do
        titles = page.all('td.title').map(&:text)
        expect(titles).to eq([
          'Oil rig safety requirements',
          'Oil rig staffing',
        ])
      end
    end

    it "deleting a list" do
      # When I visit the topic curation page
      visit_topic_list_curation_page

      # And I delete a list
      within :xpath, xpath_section_for('Oil rigs') do
        find(".delete-list").click
      end

      # Then the list should be deleted
      within '.curated-lists' do
        expect(list_titles_on_page).to eq([
          'Piping'
        ])
      end

      # And the content from the list should appear in the uncategorized section
      within '#all-list-items' do
        titles = page.all('tbody td.title').map(&:text)
        expect(titles).to eq([
          'Oil rig safety requirements',
          'Oil rig staffing',
          'North sea shipping lanes',
          'Undersea piping restrictions',
        ])
      end
    end
  end

  def visit_topic_list_curation_page
    visit topics_path
    click_on 'Offshore'
    find('#edit-list').click
  end

  def xpath_section_for(list_name)
    "//section[contains(@class, 'list')][contains(., '#{list_name}')]"
  end

  def droptarget_for_list(list_name)
    page.find(:xpath, xpath_section_for(list_name)).find('tbody')
  end

  def link_with_title(title)
    page.find(:xpath, ".//tr[.//td[@class='title'][contains(., '#{title}')]]")
  end

  def list_titles_on_page
    page.all('.list h4').map { |e| e.text.gsub(' Edit name', '') }
  end
end
