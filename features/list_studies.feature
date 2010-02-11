Feature: Contributor views deposit list
  In order to manage multiple studies I am preparing for submission
  As a contributor
  I want to view a list of my unsubmitted deposits

  Background:
    Given there is a contributor account for Alice
    And there is a contributor account for Bill
    And Alice has a study entitled "First Study"
    And Alice has a study entitled "Second Study"
    And Bill has a study entitled "Advanced Ham"


  Scenario: Alice can see her deposits, but not Bill's
    Given I am logged in as Alice
    When I go to "/studies"
    Then I should be on the study index page
    And I should see "Deposits"
    And I should see "First Study"
    And I should see "Second Study"
    But I should not see "Advanced Ham"

  Scenario: Bill can see her deposits, but not Alice's
    Given I am logged in as Bill
    When I go to "/studies"
    Then I should be on the study index page
    And I should see "Deposits"
    And I should not see "First Study"
    And I should not see "Second Study"
    But I should see "Advanced Ham"
    And I should see "incomplete"

  Scenario: One must be logged in to see any deposits
    Given I am not logged in
    When I go to "/studies"
    Then I should be on the study index page
    But I should not see "Deposits"
    And I should see "Must be logged in"
