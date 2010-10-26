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
    When I press "Apply"
    Then I should be on the study edit page for "First Study"

  Scenario Outline: Dates are normalized automatically
    When I follow "Data Description"
    And fill in "adapt_study_period_start" with "<date typed>"
    And press "Apply"
    Then the "adapt_study_period_start" field should contain "<date shown>"

  Examples:
    | date typed   | date shown  |
    | 5/85         | May 1985    |
    | Oct 10, 1923 | 10 Oct 1923 |
    | 3.5.1965     | 3 May 1965  |

  Scenario Outline: Ambiguous or indecypherable dates are rejected
    When I follow "Data Description"
    And fill in "adapt_study_period_start" with "<date typed>"
    And press "Apply"
    Then I should see "Invalid" within "label .error"

  Examples:
    | date typed  |
    | Mar 5       |
    | last year   |
    | 5 Okt 1973  |
