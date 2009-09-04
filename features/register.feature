Feature: Register
  In order to save and revisit my submissions so that I can complete the deposit
    form or add supplementary documents at a later point
  As a depositor
  I want to register a user name

  Scenario Outline: Pass or fail registration
    Given there is an account "odf"
    When I am on the registration page
    And I fill in "Username" with "<login>"
    And I fill in "Email" with "<email>@gmail.com"
    And I fill in "Password" with "<passwd>"
    And I fill in "Password confirmation" with "<confirm>"
    And I press "Submit"
    Then I should see "Registration <status>"
    And I should see "<cause>"

    Examples:

      | login | email | passwd | confirm | status  | cause                     |

      | olaf  | olaf  | geheim | geheim  | success |                           |
      | odf   | olaf  | geheim | geheim  | failed  | Username is already taken |
      | *l*f  | olaf  | geheim | geheim  | failed  | Username should use only  |
      | olaf  | olaf  | geheim | g3h31m  | failed  | Password doesn't match    |
      | olaf  | olaf  | ge     | ge      | failed  | Password is too short     |
      | olaf  | ol&f  | geheim | geheim  | failed  | Email should look like    |
