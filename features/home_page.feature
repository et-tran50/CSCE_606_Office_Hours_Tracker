Feature: Home Page
  As a user (student/TA/prof)
  I want to see the home page and about page
  So that I can get information about the Office Hours Tracker

  Scenario: Home Page Elements
    Given I am on the page "Home"
    Then I should see "Welcome"
    And I should see "Login with Google"