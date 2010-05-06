Feature: User logs in
  In order to gain the appropriate access privileges for my role
  As a user
  I want to log in to the application

  Background:
    Given there is a contributor account for Alice

  Scenario: Successful login
    When I go to the login page
    And I fill in "login" with "Alice"
    And I press "Login via ASSDA"
    Then I should see "Add study"
