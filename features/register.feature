Feature: Register
  In order to obtain a user account
  As a depositor
  I want to register

  Scenario Outline: Pass or fail registration
    When I am on the registration page
    And I fill in "Username" with "<login>"
    And I fill in "Email" with "<email>@gmail.com"
    And I fill in "Password" with "<passwd>"
    And I fill in "Password confirmation" with "<confirm>"
    And I press "Submit"
    Then I should see "Registration <status>"
    And I should see "<cause>"

  Examples:
    | login | email | passwd | confirm | status  | cause                    |
    | olaf  | olaf  | geheim | geheim  | success |                          |
    | *l*f  | olaf  | geheim | geheim  | failed  | Username should use only |
    | olaf  | olaf  | geheim | g3h31m  | failed  | Password doesn't match   |
    | olaf  | olaf  | ge     | ge      | failed  | Password is too short    |
    | olaf  | ol@f  | geheim | geheim  | failed  | Email should look like   |

  Scenario: Username exists
    Given I have an account as "olaf" with password "geheim"
    When I am on the registration page
    And I fill in "Username" with "olaf"
    And I fill in "Email" with "olaf@gmail.com"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Submit"
    Then I should see "Username is already taken"
    And I should see "Registration failed."
