Feature: Contributor edits study
  In order to add file and metadata to my submission
  As a contributor
  I want to edit a study entry

  Background:
    Given there is a contributor account for Alice
    And Alice has a study entitled "First Study"
    And I am logged in as Alice
    And I am on the study edit page for "First Study"

  Scenario: Applying changes
    When I press "Refresh"
    Then I should be on the study edit page for "First Study"

  @javascript
  Scenario: Attaching a file
    When I follow "Attached Files"
    And I attach the file "/home/olaf/vapour.c" to "Upload"
    And I attach the file "/home/olaf/warez.c" to "Upload"
    Then I should see "vapour.c"
    And I should see "warez.c"

  @focus
  @javascript
  Scenario: Filling in repeatable fields with drop-down selections
    When I follow "Data Description"
    And I click on "study_time_method_0"
    And I select "time series" from "study_time_method_0"
    And I fill in "study_time_method_1" with "something else"
    Then the "study_time_method_0" field should contain "time series"
    And the "study_time_method_1" field should contain "something else"
    And the "study_time_method_2" field should be empty
    And there should be no "study_time_method_3" field
