Feature: TA Page
  As a TA
  I want to login and see the ta page
  
  Scenario: TA logs in with mocked Google OAuth account
    Given I am logged in with name "name_ta" and email "tata@tata.com"
    Given I am on the page "Home"
    When I click "Login with Google"
    Then I should see "Howdy TA, name_ta!"

  Scenario: TA logs out
    Given I am on the page "Home"
    When I click "Login with Google"
    When I click link "Logout"
    Then I should see "Office Hours Tracker"

  Scenario: TA successfully marks attendance
    Given I am logged in as user with name "Gourangi" and email "gourangitaware@tamu.edu"
    Given I am on the page "Home"
    When I click "Login with Google"
    Then I should see "Howdy TA, Gourangi!"
    When I mark my attendance
    Then I should see "TA attendance marked successfully!"
