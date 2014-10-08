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
