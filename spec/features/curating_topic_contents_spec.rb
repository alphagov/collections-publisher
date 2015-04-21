require 'spec_helper'

RSpec.describe "Curating the contents of topics" do

  before :each do
    stub_default_publishing_api_put
    stub_default_publishing_api_put_draft
  end

  it "Curating the content for a topic" do
    #Given a number of content items tagged to a specialist sector
    oil_and_gas = create(:topic, :published, :slug => 'oil-and-gas', :title => 'Oil and Gas')
    create(:topic, :published, :slug => 'offshore', :title => 'Offshore', :parent => oil_and_gas)

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

    #Then the content should be in the correct lists in the correct order
    visit sectors_path
    click_on 'Offshore'

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
                contentapi_url_for_slug('oil-rig-safety-requirements'),
                contentapi_url_for_slug('oil-rig-staffing'),
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

  it "highlights untagged content" do
    #Given there is curated content which has been untagged
    oil_and_gas = create(:topic, :published, :slug => 'oil-and-gas', :title => 'Oil and Gas')
    create(:topic, :published, :slug => 'offshore', :title => 'Offshore', :parent => oil_and_gas)

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
        'north-sea-shipping-lanes',
        'undersea-piping-restrictions'
      ]
    )

    list = FactoryGirl.create(:list, :name => "Oil rigs", :sector_id => 'oil-and-gas/offshore')
    FactoryGirl.create(:list_item, :list => list, :api_url => contentapi_url_for_slug('oil-rig-safety-requirements'))
    FactoryGirl.create(:list_item, :list => list, :api_url => contentapi_url_for_slug('oil-rig-staffing'), :title => 'Oil rig staffing')

    #Then the untagged content should be excluded from the curated lists
    visit sectors_path
    click_on 'Offshore'

    within :xpath, "//section[@class='list'][.//h2 = 'Oil rigs']" do
      expect(page).not_to have_content(contentapi_url_for_slug('oil-rig-staffing'))
    end

    #And the untagged content should be highlighted as such
    within ".untagged-list-items" do
      expect(page).to have_content('Oil rig staffing')
    end
  end

  #Scenario: Curating draft tags
  it "curating draft tags" do
    #Given a number of content items tagged to a draft specialist sector
    oil_and_gas = create(:topic, :published, :slug => 'oil-and-gas', :title => 'Oil and Gas')
    create(:topic, :draft, :slug => 'offshore', :title => 'Offshore', :parent => oil_and_gas)

    content_api_has_draft_and_live_tags(
      :type => 'specialist_sector', :sort_order => 'alphabetical',
      :live => [
        {:slug => 'oil-and-gas', :title => 'Oil and Gas'},
      ],
      :draft => [
        {:slug => 'oil-and-gas/offshore', :title => 'Offshore', :parent => {:slug => 'oil-and-gas', :title => 'Oil and Gas'}},
      ],
    )
    content_api_has_artefacts_with_a_draft_tag(
      'specialist_sector', 'oil-and-gas/offshore',
      [ 'oil-rig-safety-requirements' ]
    )

    #Then I should be able to curate the draft sector
    visit sectors_path
    click_on 'Offshore'

    #And I should not be able to publish the draft sector
    expect(page).not_to have_selector('button', :text => 'Publish')
    expect(page).not_to have_selector('input[type="submit"]', :text => "Publish")
    expect(page).not_to have_selector('input[type="submit"][value="Publish"]')
  end
end
