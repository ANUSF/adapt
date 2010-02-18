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

  Scenario: Complete study can be submitted
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
    Then I should see the page heading "Deposit Licence"
    And I should see "As the owner of the copyright in this material"
    And I should see an "Continue" button
    And I should see an "Cancel" button

  Scenario: Incomplete study
    Given the study "First Study" has status "incomplete"
    And I am logged in as Alice
    When I submit the study "First Study"
    Then I should be on the study details page for "First Study" 
    And I should see an error message "Please supply all required information."

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
