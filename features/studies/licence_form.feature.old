Feature: Contributor signs licence form
  In order to specify ASSDA's rights on my material
  As a contributor
  I want to fill in and sign the licence form

  Background:
    Given there is a contributor account for Alice
    And Alice has a study entitled "First Study"
    And the study "First Study" has status "unsubmitted"
    And I am logged in as Alice
    And I am on the licence page for "First Study"

  Scenario: Contributor accepts licence, which is then shown for final review
    When I select "S - To be negotiated" from "Access mode"
    And I press "Continue"
    Then I should see the page heading "Deposit Licence"
    And I should see "Please review and confirm."
    And I should see "Signed: Alice"

  Scenario: Contributor does not accept licence
    When I select "S - To be negotiated" from "Access mode"
    And I press "Cancel"
    Then I should be on the study details page for "First Study"
    And I should see "unsubmitted"
    And I should see "Study not submitted."

  Scenario: No access mode selected
    When I press "Continue"
    Then I should see the page heading "Licence Form"
    And I should see an error message "Please correct the fields marked in red."
    And I should see "Please select one."

  Scenario Outline: Bad or missing form values
    When I fill in "Signed by" with "<name>"
    And I fill in "Signed date" with "<date>"
    And I fill in "Email" with "<email>"
    And I select "S - To be negotiated" from "Access mode"
    And I press "Continue"
    Then I should see the page heading "Licence Form"
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
