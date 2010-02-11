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

  Scenario: Incomplete study can be submitted
    Given the study "First Study" has status "unsubmitted"
    When I go to the study details page for "First Study"
    Then I should see a "Submit" link

  Scenario: Incomplete study cannot be submitted
    Given the study "First Study" has status "incomplete"
    When I go to the study details page for "First Study"
    Then I should not see a "Submit" link

  Scenario: License form is shown
    Given the study "First Study" has status "unsubmitted"
    When I go to the study details page for "First Study"
    And I follow "Submit"
    Then I should see the title "ASSDA Deposit Licence"
    And I should see "As the owner of the copyright in this material"
    And I should see an "Accept" button
    And I should see an "Decline" button

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
