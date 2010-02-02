Feature: Deposition
  In order to submit data to ASSDA
  As a contributor
  I want to create and manage study deposits

  Background:
    Given I exist
    And they exist
    And a study: "first" exists with owner: me, title: "My First Study"
    And a study exists with owner: me, title: "My Second Study"
    And a study exists with owner: them, title: "Advanced Ham"

  Scenario: Creating a study
    When I am logged in as myself
    And I follow "Add Study"
    And I fill in "Study title" with "The Title"
    And I fill in "Study abstract" with "Abstract yet to be written."
    And I press "Submit"
    Then I should see "Study entry created."
    And I should see "Edit Study"

  Scenario: Viewing my studies
    When I am logged in as myself
    And I follow "View Deposits"
    Then I should see "Deposits"
    And I should see "My First Study"
    And I should see "My Second Study"
    But I should not see "Advanced Ham"

  Scenario: Viewing their studies
    When I am logged in as them
    And I follow "View Deposits"
    Then I should see "Deposits"
    And I should not see "My First Study"
    And I should not see "My Second Study"
    But I should see "Advanced Ham"
    And I should see "incomplete"

  Scenario: Viewing study details
    When I am logged in as myself
    And I go to the study details page for study: "first"
    Then I should see "Study Details"
    And I should see "Title: My First Study"
