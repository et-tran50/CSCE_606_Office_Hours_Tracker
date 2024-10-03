Feature: Student Page
  As a user (student)
  I want to login and see the student page
  So that I can register I am here

  Scenario: Student logs in successfully 
    Given I'm on the page "Home"
    When I click "Login with Google"
    Then I should see "You are logged in"
    And I should see "Howdy Test"
    When I click "Mark my attendance"
    Then I should see "Attendance marked successfully!"

  Scenario: Student logs in successfully 
    Given I'm on the page "Home"
    When I click "Login with Google"
    When I click the download link
    Then the download link should point to the correct file path

  Scenario: Student logs out
    Given I'm on the page "Home"
    When I click "Login with Google"
    When I click link "Logout"
    Then I should see "You are logged out."