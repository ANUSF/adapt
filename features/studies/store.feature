Feature: Archivist stores study
  In order to create regular files that I can access from my workstation
  As an archivist
  I want to store studies that has been submitted and approved

  Background:
    Given there is a contributor account for Alice
    And there is an admin account for Bob
    And there is an archivist account for Celine
    And Alice has a study entitled "First Study"
    And I am logged in as Celine

  Scenario: Archivists can see studies assigned to them
    Given the study "First Study" has status "approved"
    And the study "First Study" has been assigned to Celine
    When I go to the study index page
    Then I should see "First Study" in the "Title" column
    And I should see "approved" in the "Status" column
    And I should see "Celine" in the "Archivist" column

  Scenario: Archivists cannot see studies assigned to someone else
    Given the study "First Study" has status "approved"
    And the study "First Study" has been assigned to Bob
    When I go to the study index page
    Then I should not see "First Study"

  Scenario: Archivists cannot see studies before they are approved
    Given the study "First Study" has status "submitted"
    When I go to the study index page
    Then I should not see "First Study"

  Scenario: Archivists can store studies with a special test id
    Given the study "First Study" has status "approved"
    And the study "First Study" has been assigned to Celine
    When I go to the study details page for "First Study"
    And I press "Store"
    Then I should see "stored"
    And I should see "test99000"
    And no mail should be sent

  Scenario: Archivists can store studies with a permanent id
    Given the study "First Study" has status "approved"
    And the study "First Study" has been assigned to Celine
    When I go to the study details page for "First Study"
    And I select "30000-39999" from "Number range for ID"
    And I press "Store"
    Then I should see "stored"
    And I should see "30000"
    And an approval notification for "First Study" should be sent
