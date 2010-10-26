Feature: Manager approves study
  In order to manage workloads and the placement of material
  As a manager
  I want to approve studies and assign them to archivists

  Background:
    Given there is a contributor account for Alice
    And there is an admin account for Bob
    And there is an archivist account for Celine
    And Alice has a study entitled "First Study"
    And I am logged in as Bob

  Scenario: Admin can see submitted studies
    Given the study "First Study" has status "submitted"
    When I go to the study index page
    Then I should see "First Study"
    And I should see "submitted"

  Scenario: Admin cannot see unsubmitted studies
    Given the study "First Study" has status "incomplete"
    When I go to the study index page
    Then I should not see "First Study"

  Scenario: Admin can approve submitted studies
    Given the study "First Study" has status "submitted"
    When I go to the study details page for "First Study"
    And I select "Celine" from "adapt_study_archivist"
    And I press "Approve"
    Then I should see "approved"

  Scenario: Admin cannot approve unsubmitted studies
    Given the study "First Study" has status "incomplete"
    When I go to the study details page for "First Study"
    Then I should not see "Approve"
