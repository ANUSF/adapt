@focus
Feature: Contributor submits study
  In order to have my work added to ASSDA's collection and to understand
    ASSDA's policies regarding the data I submit
  As a contributor
  I want to submit a completed study entry and be presented the license form
    for review

  Background:
    Given there is a contributor account for Alice
    And Alice has a study entitled "First Study"
    And I am logged in as Alice

  Scenario: License form is shown for review
    Given the study "First Study" is ready for submission
    When I go to the study edit page for "First Study"
    And I press "Submit this study"
    Then I should see the page heading "Deposit Licence"
    And I should see "Please review and confirm."
    And I should see "Signed: Alice"

  Scenario: Incomplete study
    Given the study "First Study" has status "incomplete"
    When I submit the study "First Study"
    Then I should see the page heading "Edit Study"
    And I should see an error message "not yet ready for submission"

  Scenario: Study already submitted
    Given the study "First Study" has status "submitted"
    And I am logged in as Alice
    When I submit the study "First Study"
    Then I should be on the study details page for "First Study" 
    And I should see an error message "This study has already been submitted."

  Scenario: Not owner
    Given there is a contributor account for Bob
    And I am logged in as Bob
    And I submit the study "First Study"
    Then I should see the error message "Access denied"
