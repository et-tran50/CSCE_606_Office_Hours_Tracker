Feature: Admin Page
  As a Admin
  I want to login and see the Admin page
  
  Scenario: Admin logs in with mocked Google OAuth account
    Given I am logged in with name "name_admin" and email "admin@admin.com"
    Given I am on the page "Home"
    When I click "Login with Google"
    Then I should see "Howdy Admin, name_admin!"

  Scenario: Download student attendance data
    Given I am logged in with name "name_admin" and email "admin@admin.com"
    Given I am on the page "Home"
    When I click "Login with Google"
    And  I am on the page "Admin"
    When I set the start date to "2024-10-01"
    And I set the end date to "2024-10-18"
    And I select "Student" from the admin "Attendance Type" dropdown
    And I click "Download Attendance CSV"
    Then I should receive a CSV file
    And the CSV file should contain the correct attendance data

  Scenario: Admin logs out
    Given I am on the page "Home"
    When I click "Login with Google"
    When I click link "Logout"
    Then I should see "Office Hours Tracker"