When /^I fill out the details for a new mainstream browse page$/ do
  create_mainstream_browse_page(
    slug: 'citizenship',
    title: 'Citizenship',
    description: 'Living in the UK'
  )
end

Then /^the page should be created$/ do
  check_for_mainstream_browse_page(
    title: 'Citizenship'
  )
end

Then /^the page should have been created in Panopticon$/ do
  check_mainstream_browse_page_was_created_in_panopticon(
    tag_id: 'citizenship',
    title: 'Citizenship',
    description: 'Living in the UK',
  )
end
