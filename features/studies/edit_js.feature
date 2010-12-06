@javascript
Feature: Dynamic behaviour when editing a study
  In order to save time and keystrokes and get better feedback
  As a contributor
  I want the study edit page to respond dynamically to my inputs

  Background:
    Given there is a contributor account for Alice
    And Alice has a study entitled "First Study"
    And I am logged in as Alice
    And I am on the study edit page for "First Study"

  Scenario: Edits are saved when a new tab is selected
    When I follow "Data Description"
    And fill in "Response rate:" with "90%"
    And I follow "Credits"
    Then I should see a notice "Changes were saved"

  Scenario: Nothing is saved on tab change if there were no edits
    When I follow "Data Description"
    And I follow "Credits"
    Then I should not see "Changes were saved"

  Scenario: Attaching a file
    When I follow "Attached Files"
    And attach the file "/home/olaf/vapour.c" to "Upload"
    Then I should see "vapour.c"

  @js-advanced
  Scenario: Attaching multiple files
    When I follow "Attached Files"
    And attach the file "/home/olaf/vapour.c" to "Upload"
    And attach the file "/home/olaf/warez.c" to "Upload"
    Then I should see "vapour.c"
    And I should see "warez.c"

  @js-advanced
  Scenario: Tool tips are shown when the mouse pointer stays over a field
    When I follow "Data Description"
    And I hover on "#adapt_study_data_relation"
    And I pause for 2 seconds
    Then I should see "If this study is related" within "#adapt-tooltip"
