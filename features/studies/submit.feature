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
    And I should see the notice "Please review and confirm."
    And I should see "Signed: Alice"
    And I should see an "Accept" button

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

  Scenario: Licence accepted
    Given the study "First Study" is ready for submission
    When I go to the study edit page for "First Study"
    And I press "Submit this study"
    And I press "Accept"
    Then I should see the page heading "Study Summary"
    And I should see the notice "Study submitted and pending approval"
    And a submission notification for "First Study" should be sent

  Scenario: Licence declined
    Given the study "First Study" is ready for submission
    When I go to the study edit page for "First Study"
    And I press "Submit this study"
    And I press "Cancel"
    Then I should see the page heading "Edit Study"
    And I should see the notice "Study submission has been cancelled"

  Scenario: Last minute changes are saved on submission
    Given the study "First Study" is ready for submission
    When I go to the study edit page for "First Study"
    And I follow "Title and Abstract"
    And I fill in "Study abstract" with "Gallia est omnis divisa in partes tres"
    And I press "Submit this study"
    And I press "Accept"
    Then I should see "Gallia est omnis"
