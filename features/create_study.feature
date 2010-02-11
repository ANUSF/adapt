Feature: Contributor creates study
  In order to start preparing for a data submission
  As a contributor
  I want to create a study entry

  Background:
    Given there is a contributor account for Alice
    And I am logged in as Alice
    And I am on "/studies/new"

  Scenario: Successful submission
    When I fill in "Study title" with "My Study"
    And I fill in "Study abstract" with "To be written"
    And I press "Submit"
    Then I should see "Study entry created"
    And the "Study title" field should contain "My Study"
    And the "Study abstract" field should contain "To be written"

  Scenario Outline: Missing data
    When I fill in "Study title" with "<title>"
    And I fill in "Study abstract" with "<abstract>"
    And I press "Submit"
    Then I should see "Study creation failed"
    And I should see "can't be blank"
    And the "Study title" field should contain "<title>"
    And the "Study abstract" field should contain "<abstract>"

    Examples:
      | title    | abstract      |
      | My Study |               |
      |          | To be written |

  Scenario Outline: Creation cancelled
    When I fill in "Study title" with "<title>"
    And I fill in "Study abstract" with "<abstract>"
    And I press "Cancel"
    Then I should see "Study creation cancelled"
    And I should see "Deposits"

    Examples:
      | title    | abstract      |
      | My Study | To be written |
      | My Study |               |
      |          | To be written |

  Scenario: One cannot create a study without logging in
    Given I am not logged in
    When I go to "/studies/new"
    Then I should see "Must be logged in"
    And I should not see "Study title"
