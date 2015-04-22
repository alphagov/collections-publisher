require 'spec_helper'

RSpec.describe "Curating the contents of topics with javascript UI", :js => true do

  before :each do
    stub_default_publishing_api_put
    stub_default_publishing_api_put_draft
  end

  it "Curating the content for a topic" do
    #Given a number of content items tagged to a specialist sector
    content_api_has_draft_and_live_tags(
      :type => 'specialist_sector', :sort_order => 'alphabetical',
      :live => [
        {:slug => 'oil-and-gas', :title => 'Oil and Gas'},
        {:slug => 'oil-and-gas/offshore', :title => 'Offshore', :parent => {:slug => 'oil-and-gas', :title => 'Oil and Gas'}},
      ],
      :draft => [],
    )
    content_api_has_artefacts_with_a_tag(
      'specialist_sector', 'oil-and-gas/offshore',
      [
        'oil-rig-safety-requirements',
        'oil-rig-staffing',
        'north-sea-shipping-lanes',
        'undersea-piping-restrictions'
      ]
    )

    #When I arrange the content of that specialist sector into lists
    visit sectors_path
    click_on 'Offshore'

    within '#new-list' do
      fill_in 'Name', :with => 'Oil rigs'
      click_on 'Create'
    end
    expect(page).to have_selector('.list h2', :text => 'Oil rigs')

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
    visit sectors_path
    click_on 'Offshore'

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

    #When I publish the specialist sector
    click_on('Publish')

    #Then the curated lists should have been sent to the publishing API
    assert_publishing_api_put_item(
      # The /browse here is incorrect, but is due to how the contentapi test stubs work.
      # This will be fixed when we deprecate the Sector model.
      "/browse/oil-and-gas/offshore",
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
        }
      },
    )
  end
end
