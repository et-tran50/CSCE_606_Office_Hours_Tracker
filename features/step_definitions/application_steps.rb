Given('I am on the page {string}') do |string|
  case string
  when "Home"
    visit root_path
  when "About"
    visit about_path
  when "Admin"
    admin_user = User.find_by(email: "admin@admin.com")
    visit admin_path(admin_user.id)
  when "Student"
    # I want to call it right here
  else
    raise "Path not defined for #{string}"
  end
end

When("I click {string}") do |button|
  click_button button
end

When("I click link {string}") do |link|
  click_link link
end

Then('I should see {string}') do |string|
  expect(page).to have_content(string)
end

Then('I should not see {string}') do |string|
  expect(page).to have_no_content(string)
end

When('I click the download link') do
  @download_link = find_link('Download Attendance CSV') # This finds the link by its text
end

Then('the download link should point to the correct file path') do
  expected_path = '/attendances/export_csv' # The expected path
  actual_path = @download_link[:href]

  expect(actual_path).to eq(expected_path)
end

Given('I am logged in as user with name {string} and email {string}') do |name, email|
  # Set the mock data with the specified email
  set_omniauth(name, email)
end

Then('I should see {string} in the {string} dropdown and it is selected') do |option, dropdown|
  expect(page).to have_select(dropdown, with_options: [ option ])
end

Then('I select {string} from the {string} dropdown') do |option, dropdown|
  select(option, from: dropdown)

  # dropdown_element = find(:select, dropdown)
  # options = dropdown_element.all('option').map(&:text)
  # puts "Options in the #{dropdown} dropdown: #{options.join(', ')}"
  expect(page).to have_button("CHECK IN FOR ENGR 102")
end

Then('I select {string} from the admin {string} dropdown') do |option, dropdown|
  select(option, from: dropdown)
end

Then('I should see {string} on the button with id {string}') do |button_text, button_id|
  # save_and_open_page
  expect(page).to have_button(button_text, wait: 10)
end

<<<<<<< HEAD
When("I set the start date to {string}") do |date|
  fill_in "start_date", with: date
end

When("I set the end date to {string}") do |date|
  fill_in "end_date", with: date
end

Then("I should receive a CSV file") do
  expect(page.response_headers['Content-Type']).to eq 'text/csv'
end

Then("the CSV file should contain the correct attendance data") do
  csv_content = page.body
  csv = CSV.parse(csv_content, headers: true)

  # verify the headers
  expect(csv.headers).to eq(['Date', 'Time Slot', 'Number of Students'])

  # convert the csv table to an array of hashes, which lets us use rows.first and rows.last
  rows = csv.map(&:to_h)

  # verify the date range
  expect(rows.first['Date']).to eq('2024-10-01')
  expect(rows.last['Date']).to eq('2024-10-18')

  # verify the time slots
  time_slots = csv['Time Slot'].uniq
  expected_time_slots = [
    '09:00 - 10:00', '10:00 - 11:00', '11:00 - 12:00', '12:00 - 13:00',
    '13:00 - 14:00', '14:00 - 15:00', '15:00 - 16:00', '16:00 - 17:00'
  ]
  expect(time_slots).to match_array(expected_time_slots)

  # verify the # of students is always 0 or greater
  student_counts = csv['Number of Students'].map(&:to_i)
  expect(student_counts.min).to be >= 0
end
=======

When('I mark my attendance') do
  # puts page.html  # This will print the HTML of the current page for debugging
  find('#mark-attendance-btn').click
end

>>>>>>> 55c4b43 (Cucumber Scenarios)
