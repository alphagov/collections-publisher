When /^I fill out the details for a new mainstream browse page$/ do
  create_mainstream_browse_page(
    slug: 'citizenship',
    title: 'Citizenship',
    description: 'Living in the UK'
  )
end

Then /^the page should be created$/ do
  check_for_mainstream_browse_page(
    title: 'Citizenship',
    description: 'Living in the UK'
  )
end

Then /^the page should have been created in Panopticon$/ do
  check_mainstream_browse_page_was_created_in_panopticon(
    tag_id: 'citizenship',
    title: 'Citizenship',
    description: 'Living in the UK',
  )
end

Given /^a mainstream browse page exists$/ do
  create_mainstream_browse_page(
    slug: 'citizenship',
    title: 'Citizenship',
    description: 'Living in the UK'
  )
end

When /^I make a change to the mainstream browse page$/ do
  update_mainstream_browse_page('Citizenship',
    title: 'Citizenship in the UK',
    description: 'Voting'
  )
end

Then /^the page should be updated$/ do
  check_for_mainstream_browse_page(
    title: 'Citizenship in the UK',
    description: 'Voting'
  )
end
