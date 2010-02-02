Feature: Deposition
  In order to submit data to ASSDA
  As a depositor
  I want to create and manage study deposit

  Background:
    Given I exist
    And a user: "stranger" exists
    And I am logged in as myself

  Scenario: Creating a study
    When I follow "Add Study"
    And I fill in "Study title" with "The Title"
    And I fill in "Study abstract" with "Abstract yet to be written."
    And I press "Submit"
    Then I should see "Study entry created."
    And I should see "Edit Study"

  Scenario: Study index
    Given a study exists with owner: me, title: "My First Study"
    And a study exists with owner: me, title: "My Second Study"
    And a study exists with owner: user: "stranger", title: "Advanced Ham"
    When I follow "View Deposits"
    Then I should see "Deposits"
    And I should see "My First Study"
    And I should see "My Second Study"
    But I should not see "Advanced Ham"
