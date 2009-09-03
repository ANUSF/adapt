Feature: Login
  In order to use the program
  As a user
  I want to login

  Background:
    Given I have an account as "olaf" with password "geheim"

  Scenario: Correct Password
    When I go to the login page
    And I fill in "username" with "olaf"
    And I fill in "password" with "geheim"
    And I press "Submit"
    Then I should see "Welcome olaf!"

  Scenario: Wrong Password
    When I go to the login page
    And I fill in "username" with "olaf"
    And I fill in "password" with "secret"
    And I press "Submit"
    Then I should see "Login failed."
