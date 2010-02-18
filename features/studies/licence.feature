@focus
Feature: Contributor accepts or declines licence
  In order to transfer the necessary rights on my material to ASSDA
  As a contributor
  I want to sign the licence form

  Background:
    Given there is a contributor account for Alice
    And Alice has a study entitled "First Study"
    And the study "First Study" has status "unsubmitted"
    And I am logged in as Alice
    And I am on the licence page for "First Study"

  Scenario: Licence accepted
    When I select "To be negotiated" from "Access mode"
    And I press "Continue"
    Then I should see "submitted"
    And I should see "Study successfully submitted and pending approval."
    And I should be on the study details page for "First Study"

  Scenario: Licence declined
    When I select "To be negotiated" from "Access mode"
    And I press "Cancel"
    Then I should be on the study details page for "First Study"
    And I should see "unsubmitted"
    And I should see "Study not submitted."

  Scenario Outline: Bad or missing form values
    When I fill in "Signed by" with "<name>"
    And I fill in "Signed date" with "<date>"
    And I fill in "Email" with "<email>"
    And I select "<access>" from "Access mode"
    And I press "Continue"
    Then I should see the page heading "Deposit Licence"
    And I should see an error message "Please correct the fields marked in red."
    And I should see "<message>"

    Examples:
      | name  | date     | email           | access           | message        |
      | Alice |          | alice@gmail.com | To be negotiated | Date required  |
      | Alice | today    | alice@gmail.com | To be negotiated | Unknown date   |
      | Alice | 2/5/2010 | alice@gmail.com | To be negotiated | Ambiguous date |
      | Alice | 2-5-10   | alice@gmail.com | To be negotiated | Invalid year   |
      |       | 2-5-2010 | alice@gmail.com | To be negotiated | Name required  |
      | Alice | 2-5-2010 |                 | To be negotiated | email required |
      | Alice | 2-5-2010 | alice@gmail.com |                  | Please select  |
