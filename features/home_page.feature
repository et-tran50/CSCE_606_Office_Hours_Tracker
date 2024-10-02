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