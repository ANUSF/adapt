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
    When I follow "View deposits"
    Then I should be on the study index page
    And I should see the page heading "Deposits"
    And I should see a table with 2 rows
    And I should see "Alice" in the "Created by" column
    And I should see "First Study" in the "Title" column
    And I should see "Second Study" in the "Title" column
    But I should not see "Advanced" in the "Title" column
    And I should not see "Bill" in the "Created by" column

  Scenario: Bill can see his deposits, but not Alice's
    Given I am logged in as Bill
    When I follow "View deposits"
    Then I should be on the study index page
    And I should see the page heading "Deposits"
    And I should see a table with 1 rows
    And I should see "Bill" in the "Created by" column
    And I should see "Advanced Ham" in the "Title" column
    But I should not see "Study" in the "Title" column
    And I should not see "Alice" in the "Created by" column
