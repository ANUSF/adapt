Feature: Contributor creates study
  In order to start preparing for a data submission
  As a contributor
  I want to create a study entry

  Background:
    Given there is a contributor account for Alice

  Scenario: Successful creation
    Given I am logged in as Alice
    When I follow "Add study"
    And I fill in "Study title" with "My Study"
    And I fill in "Study abstract" with "To be written"
    And I press "Save"
    Then I should see "Study entry created"
    And I should see the page heading "Edit Study"
    And the "Study title" field should contain "My Study"
    And the "Study abstract" field should contain "To be written"

  Scenario: Duplicate title
    Given Alice has a study entitled "My Study"
    And I am logged in as Alice
    When I follow "Add study"
    And I fill in "Study title" with "My study"
    And I fill in "Study abstract" with "I will fill this in later"
    And I press "Save"
    Then I should see the error message "Study creation failed"
    And I should see "You have another study with this title"

  Scenario Outline: Missing data
    Given I am logged in as Alice
    When I follow "Add study"
    And I fill in "Study title" with "<title>"
    And I fill in "Study abstract" with "<abstract>"
    And I press "Save"
    Then I should see the error message "Study creation failed"
    And I should see "May not be blank"
    And I should see the page heading "New Study"
    And the "Study title" field should contain "<title>"
    And the "Study abstract" field should contain "<abstract>"

    Examples:
      | title    | abstract      |
      |          |               |
      |          | To be written |

  Scenario Outline: Creation cancelled
    Given I am logged in as Alice
    When I follow "Add study"
    And I fill in "Study title" with "<title>"
    And I fill in "Study abstract" with "<abstract>"
    And I press "Cancel"
    Then I should see "Study creation cancelled"
    And I should see the page heading "Deposits"

    Examples:
      | title    | abstract      |
      | My Study | To be written |
      | My Study |               |
      |          | To be written |

  Scenario: One cannot create a study without logging in
    Given I am not logged in
    When I go to "/studies/new"
    Then I should see the error message "Must be logged in"

  Scenario: Archivists can create and edit studies
    Given there is an archivist account for Bill
    And I am logged in as Bill
    When I follow "Add study"
    And I fill in "Study title" with "My Study"
    And I fill in "Study abstract" with "To be written"
    And I press "Save"
    Then I should see "Study entry created"
    And I should see the page heading "Edit Study"
    And the "Study title" field should contain "My Study"
    And the "Study abstract" field should contain "To be written"
