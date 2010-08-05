@focus
Feature: Contributors cannot see or edit each others studies
  As a contributor
  I want to have exclusive edits to submissions I am working on

  Background:
    Given there is a contributor account for Alice
    And there is a contributor account for Bob
    And Alice has a study entitled "First Study"
    And I am logged in as Bob

  Scenario: Trying to view
    When I go to the study details page for "First Study"
    Then I should not see "Study Summary"
    And I should see an error message "Access denied."

  Scenario: Trying to edit
    When I go to the study edit page for "First Study"
    Then I should not see "Edit Study"
    And I should see an error message "Access denied."
