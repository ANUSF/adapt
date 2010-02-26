@focus
Feature: Contributor submits study
  In order to have my work added to ASSDA's collection and to understand
    ASSDA's policies regarding the data I submit
  As a contributor
  I want to submit a completed studie entry and be presented a license form
    for me to sign

  Background:
    Given there is a contributor account for Alice
    And Alice has a study entitled "First Study"
    And I am logged in as Alice

  Scenario: License form is shown
    Given the study "First Study" has status "unsubmitted"
    When I go to the study details page for "First Study"
    And I press "Submit this study"
    Then I should see the page heading "Licence Form"
    And I should see "As the owner of the copyright in this material"
    And I should see a "Continue" button
    And I should see a "Cancel" button

  Scenario: Incomplete study
    Given the study "First Study" has status "incomplete"
    When I go to the study details page for "First Study"
    And I press "List missing information"
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
