Feature: Student Page
  As a user (student)
  I want to login and see the student page
  So that I can register I am here

  Scenario: Student logs in with mocked Google OAuth account
    Given I am logged in with name "name_student" and email "student@student.com"
    Given I am on the page "Home"
    When I click "Login with Google"
    Then I should see "Howdy, name_student!"

  Scenario: Student logs out
    Given I am on the page "Home"
    When I click "Login with Google"
    When I click link "Logout"
    Then I should see "Office Hours Tracker"

  Scenario: When first logging in, the button should not be visible
    Given I am logged in with name "name_student" and email "student@student.com"
    Given I am on the page "Home"
    When I click "Login with Google"
    Then I should not see "CHECK IN FOR"
    Then I should see "No selection" in the "course_number" dropdown and it is selected

  Scenario: Student can select specific courses
    Given I am on the page "Home"
    Given I am logged in with name "name_student" and email "student@student.com"
    When I click "Login with Google"
    Then I select "ENGR 102" from the "course_number" dropdown
    Then I should see "CHECK IN FOR ENGR 102" on the button with id "mark-attendance-btn"
