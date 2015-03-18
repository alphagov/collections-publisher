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

Then /^the page should be in the "(.*)" state$/ do |state|
  check_state_of_mainstream_browse_page(
    title: 'Citizenship',
    state: state
  )
end

Given /^a draft mainstream browse page exists$/ do
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

Then /^the page should have been updated in Panopticon$/ do
  check_mainstream_browse_page_was_updated_in_panopticon(
    tag_id: 'citizenship',
    title: 'Citizenship in the UK',
    description: 'Voting',
  )
end

When /^I fill out the details for a new child browse page$/ do
  create_child_mainstream_browse_page(
    parent: 'Citizenship',
    slug: 'voting',
    title: 'Voting',
    description: 'Register to vote, postal voting forms',
  )
end

Then /^the child page should be created$/ do
  check_for_child_mainstream_browse_page(
    parent: 'Citizenship',
    title: 'Voting',
    description: 'Register to vote, postal voting forms'
  )
end

Then /^the child page should have been created in Panopticon$/ do
  check_mainstream_browse_page_was_created_in_panopticon(
    tag_id: 'citizenship/voting',
    title: 'Voting',
    description: 'Register to vote, postal voting forms',
    parent_id: 'citizenship'
  )
end

When /^I publish the browse page$/ do
  publish_mainstream_browse_page('Citizenship')
end

Then /^the page should have been published in Panopticon$/ do
  check_mainstream_browse_page_was_published_in_panopticon(
    tag_id: 'citizenship'
  )
end
