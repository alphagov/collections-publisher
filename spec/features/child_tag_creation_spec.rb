require 'rails_helper'

RSpec.describe 'creating child tags' do
  before do
    stub_user.permissions << "GDS Editor"
  end

  it 'populates the parent_id input field given a parent_id parameter' do
    parent_browse_page = create(:mainstream_browse_page)
    visit new_mainstream_browse_page_path(parent_id: parent_browse_page.id)

    parent_label_field = page.find('#parent-name')
    parent_id_field = page.find('#mainstream_browse_page_parent_id')

    expect(parent_label_field.value).to match(parent_browse_page.title)
    expect(parent_id_field.value).to eq(parent_browse_page.id.to_s)
  end

  it 'still populates the parent_id field on form submission with errors' do
    parent_browse_page = create(:mainstream_browse_page)

    visit new_mainstream_browse_page_path(parent_id: parent_browse_page.id)
    click_on 'Create' # submits the form with errors

    parent_label_field = page.find('#parent-name')
    parent_id_field = page.find('#mainstream_browse_page_parent_id')

    expect(parent_label_field.value).to match(parent_browse_page.title)
    expect(parent_id_field.value).to eq(parent_browse_page.id.to_s)
  end

end
