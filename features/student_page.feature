Feature: Student Page
  As a user (student)
  I want to login and see the student page
  So that I can register I am here

  Scenario: Student Page Elements
    Given I'm on the page "Student"
    Then I should see "Howdy"
    When I click "Mark my attendance"
    Then I should see "Attendence marked successfully!"