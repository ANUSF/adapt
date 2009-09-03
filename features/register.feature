Feature: Register
  In order to obtain a user account
  As a depositor
  I want to register

  Scenario: Correct Registration
    When I am on the registration page
    And I fill in "Username" with "olaf"
    And I fill in "Email" with "olaf@gmail.com"
    And I fill in "Password" with "geheim"
    And I fill in "Password confirmation" with "geheim"
    And I press "Submit"
    Then I should see "Registration successful."

  Scenario: Password Confirmation Mismatch
    When I am on the registration page
    And I fill in "Username" with "olaf"
    And I fill in "Email" with "olaf@gmail.com"
    And I fill in "Password" with "geheim"
    And I fill in "Password confirmation" with "g3h31m"
    And I press "Submit"
    Then I should see "Password doesn't match confirmation"

  Scenario: Password Too Short
    When I am on the registration page
    And I fill in "Username" with "olaf"
    And I fill in "Email" with "olaf@gmail.com"
    And I fill in "Password" with "pw"
    And I fill in "Password confirmation" with "pw"
    And I press "Submit"
    Then I should see "Password is too short"

  Scenario: Bad Email Address
    When I am on the registration page
    And I fill in "Username" with "olaf"
    And I fill in "Email" with "olaf%gmail.com"
    And I fill in "Password" with "geheim"
    And I fill in "Password confirmation" with "geheim"
    And I press "Submit"
    Then I should see "Email should look like an email address"

  Scenario: Username exists
    Given I have an account as "olaf" with password "geheim"
    When I am on the registration page
    And I fill in "Username" with "olaf"
    And I fill in "Email" with "olaf@gmail.com"
    And I fill in "Password" with "secret"
    And I fill in "Password confirmation" with "secret"
    And I press "Submit"
    Then I should see "Username is already taken"
