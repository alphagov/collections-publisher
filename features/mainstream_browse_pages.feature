Feature: Mainstream browse pages

  @mock-panopticon
  Scenario: Creating a page
    When I fill out the details for a new mainstream browse page
    Then the page should be created
    And the page should have been created in Panopticon
