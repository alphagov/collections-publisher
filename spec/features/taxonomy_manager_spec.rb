require "rails_helper"

RSpec.feature "Managing taxonomies" do
  before do
    stub_user.permissions << "Edit Taxonomy"
    @item_1 = { title: "I Am A Taxon", content_id: "ID-1", base_path: "/foo" }
    @item_2 = { title: "I Am Another Taxon", content_id: "ID-2", base_path: "/bar" }

    @create_item = stub_request(:put, %r[https://publishing-api.test.gov.uk/v2/content*]).
      to_return(status: 200, body: {}.to_json)

    @publish_item = stub_request(:post, %r[https://publishing-api.test.gov.uk/v2/.*/publish]).
      to_return(status: 200, body: {}.to_json)

    @create_links = stub_request(:patch, %r[https://publishing-api.test.gov.uk/v2/links*]).
      to_return(status: 200, body: {}.to_json)
  end

  scenario "User creates a taxon with multiple parents" do
    given_there_are_taxons
    when_I_visit_the_taxonomy_page
    and_I_click_on_the_new_taxon_button
    when_I_submit_the_form_with_a_title_and_parents
    then_a_taxon_is_created
  end

  scenario "User edits a taxon" do
    given_there_are_taxons
    when_I_visit_the_taxonomy_page
    and_I_click_on_the_edit_taxon_link
    when_I_submit_the_form_with_a_title_and_parents
    then_my_taxon_is_updated
  end

  def and_I_click_on_the_edit_taxon_link
    first('a', text: 'Edit taxon').click
  end

  def given_there_are_taxons
    stub_request(:get, "https://publishing-api.test.gov.uk/v2/linkables?document_type=taxon").
      to_return(body: [@item_1, @item_2].to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/links/ID-1").
      to_return(body: { links: { parent: [] } }.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-1").
      to_return(body: @item_1.to_json)

    stub_request(:get, "https://publishing-api.test.gov.uk/v2/content/ID-2").
      to_return(body: @item_2.to_json)
  end

  def when_I_visit_the_taxonomy_page
    visit taxons_path
  end

  def and_I_click_on_the_new_taxon_button
    click_on "Add a taxon"
  end

  def when_I_submit_the_form_with_a_title_and_parents
    fill_in :taxon_form_title, with: "My Lovely Taxon"

    select @item_1[:title]
    expect(find('#taxon_form_parents').value).to include(@item_1[:content_id])

    select @item_2[:title]
    expect(find('#taxon_form_parents').value).to include(@item_2[:content_id])

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
