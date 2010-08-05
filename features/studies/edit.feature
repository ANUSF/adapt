@javascript
@focus
Feature: Contributor edits study
  In order to add file and metadata to my submission
  As a contributor
  I want to edit a study entry

  Background:
    Given there is a contributor account for Alice
    And Alice has a study entitled "First Study"
    And I am logged in as Alice
    And I am on the study edit page for "First Study"

  Scenario: The edit screen is split into tabs
    When I follow "Data Description"
    Then I should be on the study edit page for "First Study"
    And I should see "Sampling procedures"
    And I should see "Other Acknowledgements"

  Scenario: Applying changes
    When I press "Apply Changes"
    Then I should be on the study edit page for "First Study"

  Scenario: Attaching a file
    When I follow "Attached Files"
    And I attach the file "/home/olaf/jsmin.c" to "Upload"
    Then I should see "jsmin.c"
