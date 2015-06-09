require 'rails_helper'

RSpec.describe "Curating the contents of topics" do
  before :each do
    stub_default_publishing_api_put
    stub_default_publishing_api_put_draft
  end

  describe "Curating the content for a topic" do
    before :each do
      # Given a number of content items tagged to a topic
      oil_and_gas = create(:topic, :published, :slug => 'oil-and-gas', :title => 'Oil and Gas')
      create(:topic, :published, :slug => 'offshore', :title => 'Offshore', :parent => oil_and_gas)

      content_api_has_artefacts_with_a_tag(
        'specialist_sector', 'oil-and-gas/offshore',
        [
          'oil-rig-safety-requirements',
          'oil-rig-staffing',
          'north-sea-shipping-lanes',
          'undersea-piping-restrictions'
        ]
      )
    end

    it "with javascript", :js => true do
      # When I arrange the content of that topic into lists
      visit_topic_list_curation_page

      within '#list-uncategorized-section' do
        expect(page).not_to have_content('These will not be displayed to users')
      end

      within '#new-list' do
        fill_in 'Name', :with => 'Oil rigs'
        click_on 'Create'
      end

      # We need to scroll down first to see all the lists.
      page.driver.scroll_to 0, 100

      expect(page).to have_selector('.list h2', :text => 'Oil rigs')

      within '#list-uncategorized-section' do
        expect(page).to have_content('These will not be displayed to users')
      end

      target = page.find(:xpath, "//section[contains(@class, 'list')][.//h2 = 'Oil rigs']//tbody[contains(@class, 'curated-list')]")
      within '#list-uncategorized-section' do
        page.find(:xpath, ".//*[contains(@class,'ui-sortable-handle')][.//td[@class='title'] = 'Oil rig safety requirements']")
          .drag_to(target)
      end
      within :xpath, "//section[contains(@class, 'list')][.//h2 = 'Oil rigs']" do
        expect(page).to have_content('Oil rig safety requirements')
        expect(page).not_to have_css(".working") # Wait until the AJAX call has completed
      end
      within '#list-uncategorized-section' do
        page.find(:xpath, ".//*[contains(@class,'ui-sortable-handle')][.//td[@class='title'] = 'Oil rig staffing']")
          .drag_to(target)
      end
      within :xpath, "//section[contains(@class, 'list')][.//h2 = 'Oil rigs']" do
        expect(page).to have_content('Oil rig staffing')
        expect(page).not_to have_css(".working") # Wait until the AJAX call has completed
      end

      within '#new-list' do
        fill_in 'Name', :with => 'Piping'
        click_on 'Create'
      end
      expect(page).to have_selector('.list h2', :text => 'Piping')

      target = page.find(:xpath, "//section[contains(@class, 'list')][.//h2 = 'Piping']//tbody[contains(@class, 'curated-list')]")
      within '#list-uncategorized-section' do
        page.find(:xpath, ".//*[contains(@class,'ui-sortable-handle')][.//td[@class='title'] = 'Undersea piping restrictions']")
          .drag_to(target)
      end

      within :xpath, "//section[contains(@class, 'list')][.//h2 = 'Piping']" do
        expect(page).to have_content('Undersea piping restrictions')
        expect(page).not_to have_selector(".working") # Wait until the AJAX call has completed
      end

      #Then the content should be in the correct lists in the correct order
      visit_topic_list_curation_page

      within :xpath, "//section[contains(@class,'list')][.//h2 = 'Oil rigs']" do
        titles = page.all('td.title').map(&:text)
        # Note: order reversed because we dragged the items to the top of the list above.
        expect(titles).to eq([
          'Oil rig staffing',
          'Oil rig safety requirements',
        ])
      end

      within :xpath, "//section[contains(@class,'list')][.//h2 = 'Piping']" do
        titles = page.all('td.title').map(&:text)
        expect(titles).to eq([
          'Undersea piping restrictions',
        ])
      end

      # When I publish the topic
      click_on('Publish changes to GOV.UK')

      #Then the curated lists should have been sent to the publishing API
      assert_publishing_api_put_item(
        "/oil-and-gas/offshore",
        {
          "details" => {
            "groups" => [
              { "name" => 'Oil rigs',
                "contents" => [
                  contentapi_url_for_slug('oil-rig-staffing'),
                  contentapi_url_for_slug('oil-rig-safety-requirements'),
              ]},
              { "name" => 'Piping',
                "contents" => [
                  contentapi_url_for_slug('undersea-piping-restrictions'),
              ]},
            ],
            "beta" => false,
          }
        },
      )
    end

    it "without javascript" do
      # When I arrange the content of that topic into lists
      visit_topic_list_curation_page

      within '#list-uncategorized-section' do
        expect(page).not_to have_content('These will not be displayed to users')
      end

      within '#new-list' do
        fill_in 'Name', :with => 'Oil rigs'
        click_on 'Create'
      end

      within '#list-uncategorized-section' do
        expect(page).to have_content('These will not be displayed to users')
      end

      within :xpath, "//section[@class='list'][.//h2 = 'Oil rigs']" do
        fill_in 'API URL', :with => contentapi_url_for_slug('oil-rig-safety-requirements')
        fill_in 'Index', :with => 0
        click_on 'Add'
        fill_in 'API URL', :with => contentapi_url_for_slug('oil-rig-staffing')
        fill_in 'Index', :with => 1
        click_on 'Add'
      end
      within '#new-list' do
        fill_in 'Name', :with => 'Piping'
        click_on 'Create'
      end
      within :xpath, "//section[@class='list'][.//h2 = 'Piping']" do
        fill_in 'API URL', :with => contentapi_url_for_slug('undersea-piping-restrictions')
        fill_in 'Index', :with => 0
        click_on 'Add'
      end

      # Then the content should be in the correct lists in the correct order
      visit_topic_list_curation_page

      within :xpath, "//section[@class='list'][.//h2 = 'Oil rigs']" do
        api_urls = page.all('td.api-url').map(&:text)
        expect(api_urls).to eq([
          contentapi_url_for_slug('oil-rig-safety-requirements'),
          contentapi_url_for_slug('oil-rig-staffing'),
        ])
      end
      within :xpath, "//section[@class='list'][.//h2 = 'Piping']" do
        api_urls = page.all('td.api-url').map(&:text)
        expect(api_urls).to eq([
          contentapi_url_for_slug('undersea-piping-restrictions'),
        ])
      end

      # When I publish the topic
      click_on('Publish changes to GOV.UK')

      #Then the curated lists should have been sent to the publishing API
      assert_publishing_api_put_item(
        "/oil-and-gas/offshore",
        {
          "details" => {
            "groups" => [
              { "name" => 'Oil rigs',
                "contents" => [
                  contentapi_url_for_slug('oil-rig-safety-requirements'),
                  contentapi_url_for_slug('oil-rig-staffing'),
              ]},
              { "name" => 'Piping',
                "contents" => [
                  contentapi_url_for_slug('undersea-piping-restrictions'),
              ]},
            ],
            "beta" => false,
          }
        },
      )
    end
  end

  it "curating draft tags" do
    # Given a number of content items tagged to a draft topic
    oil_and_gas = create(:topic, :published, :slug => 'oil-and-gas', :title => 'Oil and Gas')
    create(:topic, :draft, :slug => 'offshore', :title => 'Offshore', :parent => oil_and_gas)

    content_api_has_artefacts_with_a_draft_tag(
      'specialist_sector', 'oil-and-gas/offshore',
      [ 'oil-rig-safety-requirements' ]
    )

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

      content_api_has_artefacts_with_a_tag(
        'specialist_sector', 'oil-and-gas/offshore',
        [
          'oil-rig-safety-requirements',
          'oil-rig-staffing',
          'north-sea-shipping-lanes',
          'undersea-piping-restrictions'
        ]
      )

      oil_rigs = create(:list, :tag => offshore, :name => 'Oil rigs', :index => 0)
      piping = create(:list, :tag => offshore, :name => 'Piping', :index => 1)

      create(:list_item, :list => oil_rigs, :index => 0, :title => 'Oil rig safety requirements', :api_url => contentapi_url_for_slug('oil-rig-safety-requirements'))
      create(:list_item, :list => oil_rigs, :index => 1, :title => 'Oil rig staffing', :api_url => contentapi_url_for_slug('oil-rig-staffing'))
      create(:list_item, :list => piping, :index => 0, :title => 'Undersea piping restrictions', :api_url => contentapi_url_for_slug('undersea-piping-restrictions'))
      create(:list_item, :list => piping, :index => 1, :title => 'Non-existent', :api_url => contentapi_url_for_slug('non-existent'))
    end

    it "viewing the topic curation page" do
      # When I visit the topic curation page
      visit_topic_list_curation_page

      # Then I should see the curated topic groups
      within '.curated-lists' do
        list_titles = page.all('.list h2').map(&:text)
        expect(list_titles).to eq([
          'Oil rigs',
          'Piping',
        ])

        within :xpath, ".//section[@class='list'][.//h2 = 'Oil rigs']" do
          titles = page.all('td.title').map(&:text)
          expect(titles).to eq([
            'Oil rig safety requirements',
            'Oil rig staffing',
          ])
        end
        within :xpath, ".//section[@class='list'][.//h2 = 'Piping']" do
          titles = page.all('td.title').map(&:text)
          expect(titles).to eq([
            'Undersea piping restrictions',
            'Non-existent',
          ])
        end
      end

      # And I should see the content that hasn't been added to groups
      within '#list-uncategorized-section' do
        titles = page.all('tbody td.title').map(&:text)
        expect(titles).to eq([
          'North sea shipping lanes',
        ])
      end
    end

    it "editing a list name" do
      # When I visit the topic curation page
      visit_topic_list_curation_page

      # And I change the name of a list
      within :xpath, ".//section[@class='list'][.//h2 = 'Oil rigs']" do
        click_on "Edit name"
      end
      fill_in "Name", :with => 'Oil platforms'
      click_on "Save"

      # Then I should see the updated list name
      within '.curated-lists' do
        list_titles = page.all('.list h2').map(&:text)
        expect(list_titles).to eq([
          'Oil platforms',
          'Piping',
        ])
      end

      # And it should retain its content
      within :xpath, ".//section[@class='list'][.//h2 = 'Oil platforms']" do
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
      within :xpath, ".//section[@class='list'][.//h2 = 'Oil rigs']" do
        click_on "Delete list"
      end

      # Then the list should be deleted
      within '.curated-lists' do
        list_titles = page.all('.list h2').map(&:text)
        expect(list_titles).to eq([
          'Piping',
        ])
      end

      # And the content from the list should appear in the uncategorized section
      within '#list-uncategorized-section' do
        titles = page.all('tbody td.title').map(&:text)
        expect(titles).to eq([
          'Oil rig safety requirements',
          'Oil rig staffing',
          'North sea shipping lanes',
        ])
      end
    end
  end

  def visit_topic_list_curation_page
    visit topics_path
    click_on 'Offshore'
    click_on 'Edit list'
  end
end
