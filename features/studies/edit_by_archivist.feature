Feature: Contributor edits study
  In order to speed up the curation process
  As an archivist
  I want to use additional features when editing a study

  Background:
    Given there is a archivist account for Alice
    And Alice has a study entitled "First Study"
    And I am logged in as Alice
    And I am on the study edit page for "First Study"

  Scenario Outline: The skip licence checkbox works
    When I follow "Licence Details"
    And I <action> "Licence will be obtained separately"
    And press "Apply"
    Then the "Licence will be obtained separately" checkbox should <state>

  Examples:
    | action  | state          |
    | check   | be checked     |
    | uncheck | not be checked |
