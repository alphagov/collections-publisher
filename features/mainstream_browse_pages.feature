Feature: Mainstream browse pages

  @mock-panopticon
  Scenario: Creating a page
    When I fill out the details for a new mainstream browse page
    Then the page should be created
    And the page should be in the "draft" state
    And the page should have been created in Panopticon

  @mock-panopticon
  Scenario: Updating a page
    Given a draft mainstream browse page exists
    When I make a change to the mainstream browse page
    Then the page should be updated
    And the page should have been updated in Panopticon

  @mock-panopticon
  Scenario: Creating a child browse page
    Given a draft mainstream browse page exists
    When I fill out the details for a new child browse page
    Then the child page should be created
    And the child page should have been created in Panopticon

  @mock-panopticon
  Scenario: Publishing a page
    Given a draft mainstream browse page exists
    When I publish the browse page
    Then the page should be in the "published" state
    And the page should have been published in Panopticon
