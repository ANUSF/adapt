Feature: Depositing
  In order to prepare for submission of my study data to ASSDA
  As a contributor
  I want to create and manage study descriptions, also called deposits

  Background:
    Given there is a contributor account for Alice
    And there is a contributor account for Bill
    And Alice has a study entitled "First Study"
    And Alice has a study entitled "Second Study"
    And Bill has a study entitled "Advanced Ham"

  Scenario: Creating a study
    Given I am logged in as Alice
    When I follow "Add Study"
    And I fill in "Study title" with "The Title"
    And I fill in "Study abstract" with "Abstract yet to be written."
    And I press "Submit"
    Then I should see "Study entry created."
    And I should see "Edit Study"
    And I should see "The Title"

  Scenario: Viewing Alice's deposits
    Given I am logged in as Alice
    When I follow "View Deposits"
    Then I should be on the study index page
    And I should see "Deposits"
    And I should see "First Study"
    And I should see "Second Study"
    But I should not see "Advanced Ham"

  Scenario: Viewing Bill's deposits
    Given I am logged in as Bill
    When I follow "View Deposits"
    Then I should be on the study index page
    And I should see "Deposits"
    And I should not see "First Study"
    And I should not see "Second Study"
    But I should see "Advanced Ham"
    And I should see "incomplete"

  Scenario: Viewing study details
    Given I am logged in as Alice
    When I go to the study details page for "First Study"
    Then I should see "Study Details"
    And I should see "Title: First Study"

  Scenario: Contributors can't see each other's studies
    Given I am logged in as Bill
    When I go to the study details page for "First Study"
    Then I should see "Access denied"
    And I should not see "Title: First Study"

  Scenario: Removing a study
    Given I am logged in as Alice
    And I am on the study details page for "First Study"
    When I follow "Delete"
    Then I should be on the study index page
    And I should not see "First Study"
    But I should see "Second Study"
