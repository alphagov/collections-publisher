require "rails_helper"

RSpec.feature "Managing taxonomies" do
  before do
    stub_user.permissions << "Edit Taxonomy"

    @create_item = stub_request(:put, %r[https://publishing-api.test.gov.uk/v2/content*]).
      to_return(status: 200, body: {}.to_json)

    @publish_item = stub_request(:post, %r[https://publishing-api.test.gov.uk/v2/.*/publish]).
      to_return(status: 200, body: {}.to_json)

    @create_links = stub_request(:put, %r[https://publishing-api.test.gov.uk/v2/links*]).
      to_return(status: 200, body: {}.to_json)
  end

  scenario "User creates a taxon" do
    given_there_is_a_taxon
    when_I_visit_the_taxonomy_page
    and_I_click_on_the_new_taxon_button
    when_I_submit_the_form_with_a_title
    then_a_taxon_is_created
  end

  scenario "User edits a taxon" do
    given_there_is_a_taxon
    when_I_visit_the_taxonomy_page
    and_I_click_on_the_edit_taxon_link
    when_I_submit_the_form_with_a_title
    then_my_taxon_is_updated
  end

  def and_I_click_on_the_edit_taxon_link
    click_on "Edit taxon"
  end

  def given_there_is_a_taxon
    item = { title: "I Am A Taxon", content_id: "ID-1", base_path: "/foo" }

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content?content_format=taxon&fields%5B%5D=base_path&fields%5B%5D=content_id&fields%5B%5D=title").
      to_return(body: [item].to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/links/ID-1").
      to_return(body: { links: { parent: [] } }.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-1").
      to_return(body: item.to_json)
  end

  def when_I_visit_the_taxonomy_page
    visit taxons_path
  end

  def and_I_click_on_the_new_taxon_button
    click_on "Add a taxon"
  end

  def when_I_submit_the_form_with_a_title
    fill_in :taxon_form_title, with: "My Lovely Taxon"
    click_on "Save"
  end

  def then_a_taxon_is_created
    expect(@create_item).to have_been_requested
    expect(@publish_item).to have_been_requested
    expect(@create_links).to have_been_requested
  end

  def then_my_taxon_is_updated
    then_a_taxon_is_created
  end
end
