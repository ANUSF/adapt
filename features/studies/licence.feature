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
    When I select "S - To be negotiated" from "Access mode"
    And I press "Continue"
    Then I should see "submitted"
    And I should see "Study successfully submitted and pending approval."
    And I should be on the study details page for "First Study"

  Scenario: No access mode selected
    When I press "Continue"
    Then I should see the page heading "Deposit Licence"
    And I should see an error message "Please correct the fields marked in red."
    And I should see "Please select one."

  Scenario: Licence declined
    When I select "S - To be negotiated" from "Access mode"
    And I press "Cancel"
    Then I should be on the study details page for "First Study"
    And I should see "unsubmitted"
    And I should see "Study not submitted."

  Scenario Outline: Bad or missing form values
    When I fill in "Signed by" with "<name>"
    And I fill in "Signed date" with "<date>"
    And I fill in "Email" with "<email>"
    And I select "S - To be negotiated" from "Access mode"
    And I press "Continue"
    Then I should see the page heading "Deposit Licence"
    And I should see an error message "Please correct the fields marked in red."
    And I should see "<message>"

    Examples:
      | name         | date     | email           | message        |
      | Alice Cooper |          | alice@gmail.com | Date required  |
      | Alice Cooper | today    | alice@gmail.com | Unknown date   |
      | Alice Cooper | 2/5/2010 | alice@gmail.com | Ambiguous date |
      | Alice Cooper | 2-5-10   | alice@gmail.com | Invalid year   |
      |              | 2-5-2010 | alice@gmail.com | Name required  |
      | Alice Cooper | 2-5-2010 |                 | email required |
      | Alice Cooper | 2-5-2010 | @lice@gmail.com | Invalid email  |
      | Alic3 Cooper | 2-5-2010 | alice@gmail.com | Invalid name   |
      | Alice_Cooper | 2-5-2010 | alice@gmail.com | Invalid name   |
      | @lice Cooper | 2-5-2010 | alice@gmail.com | Invalid name   |
