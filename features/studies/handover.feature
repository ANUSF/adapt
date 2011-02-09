Feature: Archivist hands over study to another
  In order to allow another archivist to add data files or metadata
  As an archivist
  I want to hand over a study that has been assigned to me

  Background:
    Given there is a contributor account for Alice
    And there is an archivist account for Bob
    And there is an archivist account for Celine
    And there is an admin account for Dan
    And Alice has a study entitled "First Study"
    And the study "First Study" has status "submitted"
    And the study "First Study" has been assigned to Bob

  Scenario: Archivists can hand over a study
    Given I am logged in as Bob
    When I go to the study details page for "First Study"
    And I select "Celine" from "archivist"
    And I press "Hand over"
    Then I should see "Study handover successful!"
    And a notification that "Bob" handed over "First Study" should be sent
    And I should see "Archivist: Celine"

  Scenario: Admins can hand over a study
    Given I am logged in as Dan
    When I go to the study details page for "First Study"
    And I select "Celine" from "archivist"
    And I press "Hand over"
    Then I should see "Study handover successful!"
    And a notification that "Bob" handed over "First Study" should be sent
    And I should see "Archivist: Celine"

  Scenario: Owners cannot hand over a study
    Given I am logged in as Alice
    When I go to the study details page for "First Study"
    Then I should not see "Hand over"