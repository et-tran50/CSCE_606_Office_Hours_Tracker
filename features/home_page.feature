Feature: Home Page
  As a user (student/TA/prof)
  I want to see the home page and about page
  So that I can get information about the Office Hours Tracker

  Scenario: Home Page Elements
    Given I'm on the page "Home"
    Then I should see "Welcome to the Home Page"
    And I should see "We are Office-Hours-Tracker."

  Scenario: About Page Elements
    Given I'm on the page "About"
    Then I should see "Home#about"
    And I should see "Find me in app/views/home/about.html.erb"

Feature: Record Attendance
  As a student/TA
  I want to show I am here
  so that the system can record my attendance

  Scenario: Student enter the queue
    Given I am logged in as "student@tamu.edu"
    Then I should see "Join Queue"
    When I press "Join Queue"
    Then I should see "You have entered the queue!"