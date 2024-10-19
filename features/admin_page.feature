Feature: Admin Page
  As a Admin
  I want to login and see the Admin page
  
  Scenario: Admin logs in with mocked Google OAuth account
    Given I am logged in as user with name "name_admin" and email "admin@admin.com"
    Given I am on the page "Home"
    When I click "Login with Google"
    Then I should see "Howdy, name_admin!"

  Scenario: Admin logs out
    Given I am on the page "Home"
    When I click "Login with Google"
    When I click link "Logout"
    Then I should see "Office Hours Tracker"
