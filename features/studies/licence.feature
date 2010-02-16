Feature: Contributor accepts or declines licence
  In order to transfer the necessary rights on my material to ASSDA
  As a contributor
  I want to sign the licence form

  Background:
    Given there is a contributor account for Alice
    And Alice has a study entitled "First Study"
    And I am logged in as Alice

  Scenario: Licence accepted
    Given the study "First Study" has status "unsubmitted"
    When I go to the study details page for "First Study"
    And I follow "Submit"
    And I press "Accept"
    Then I should be on the study details page for "First Study"
    And I should see "Status: submitted"
    And I should see "Study successfully submitted and pending approval."

  Scenario: Licence declined
    Given the study "First Study" has status "unsubmitted"
    When I go to the study details page for "First Study"
    And I follow "Submit"
    And I press "Decline"
    Then I should be on the study details page for "First Study"
    And I should see "Status: unsubmitted"
    And I should see "Study not submitted."
