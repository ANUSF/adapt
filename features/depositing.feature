Feature: Depositing
  In order to submit data to ASSDA
  As a contributor
  I want to create and manage study deposits

  Background:
    Given I exist with role: "contributor"
    And they exist with role: "contributor"
    And a study: "first" exists with owner: me, title: "My First Study"
    And a study exists with owner: me, title: "My Second Study"
    And a study exists with owner: them, title: "Advanced Ham"

  Scenario: Creating a study
    Given I am logged in as myself
    When I follow "Add Study"
    And I fill in "Study title" with "The Title"
    And I fill in "Study abstract" with "Abstract yet to be written."
    And I press "Submit"
    Then I should see "Study entry created."
    And I should see "Edit Study"
    And I should see "The Title"

  Scenario: Viewing my studies
    Given I am logged in as myself
    When I follow "View Deposits"
    Then I should be on the study index page
    And I should see "Deposits"
    And I should see "My First Study"
    And I should see "My Second Study"
    But I should not see "Advanced Ham"

  Scenario: They viewing their studies
    Given I am logged in as them
    When I follow "View Deposits"
    Then I should be on the study index page
    And I should see "Deposits"
    And I should not see "My First Study"
    And I should not see "My Second Study"
    But I should see "Advanced Ham"
    And I should see "incomplete"

  Scenario: Viewing study details
    Given I am logged in as myself
    When I go to the study details page for study: "first"
    Then I should see "Study Details"
    And I should see "Title: My First Study"

  Scenario: Other contributors can not see my studies
    Given I am logged in as them
    When I go to the study details page for study: "first"
    Then I should see "Access denied"
    And I should not see "Title: My First Study"

  Scenario: Removing a study
    Given I am logged in as myself
    And I am on the study details page for study: "first"
    When I follow "Delete"
    Then I should be on the study index page
    And I should not see "My First Study"
    But I should see "My Second Study"
